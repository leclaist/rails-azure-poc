terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  # The resource group and ACR were provisioned in eastus before eastus2 was
  # chosen for Container Apps (eastus had capacity issues at creation time).
  rg_location  = "eastus"
  app_location = "eastus2"
}

# ---------------------------------------------------------------------------
# Resource group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = "rails-azure-poc-rg"
  location = local.rg_location
}

# ---------------------------------------------------------------------------
# Azure Container Registry
# ---------------------------------------------------------------------------

resource "azurerm_container_registry" "main" {
  name                = "railsazurepocacr"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.rg_location
  sku                 = "Basic"
  admin_enabled       = true
}

# ---------------------------------------------------------------------------
# Log Analytics workspace
# ---------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = "workspace-railsazurepocrgWsSn"
  location            = local.app_location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---------------------------------------------------------------------------
# Container Apps environment
#
# The Log Analytics workspace is attached via a one-time CLI command after
# `terraform apply`, because azurerm 3.x treats log_analytics_workspace_id
# as ForceNew — setting it here would destroy and recreate the environment.
# Run this once after the first apply:
#
#   WORKSPACE_ID=$(az monitor log-analytics workspace show \
#     --resource-group rails-azure-poc-rg \
#     --workspace-name workspace-railsazurepocrgWsSn \
#     --query customerId -o tsv)
#   WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
#     --resource-group rails-azure-poc-rg \
#     --workspace-name workspace-railsazurepocrgWsSn \
#     --query primarySharedKey -o tsv)
#   az containerapp env update \
#     --name rails-azure-poc-env2 --resource-group rails-azure-poc-rg \
#     --logs-destination log-analytics \
#     --logs-workspace-id "$WORKSPACE_ID" \
#     --logs-workspace-key "$WORKSPACE_KEY"
# ---------------------------------------------------------------------------

resource "azurerm_container_app_environment" "main" {
  name                = "rails-azure-poc-env2"
  location            = local.app_location
  resource_group_name = azurerm_resource_group.main.name
}

# ---------------------------------------------------------------------------
# Storage account + file share
#
# Provisioned for potential future use (e.g. uploaded files). Not used for
# SQLite — Azure Files SMB does not support the POSIX file locking SQLite
# requires. The app uses ephemeral container storage for the database.
# ---------------------------------------------------------------------------

resource "azurerm_storage_account" "main" {
  name                     = "railsazurepocdata"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = local.app_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
}

resource "azurerm_storage_share" "main" {
  name                 = "rails-azure-poc-data"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 50
}

resource "azurerm_container_app_environment_storage" "main" {
  name                         = "sqlite-storage"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.main.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}

# ---------------------------------------------------------------------------
# Container App
# ---------------------------------------------------------------------------

resource "azurerm_container_app" "main" {
  name                         = "rails-azure-poc"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.main.admin_password
  }

  secret {
    name  = "rails-master-key"
    value = var.rails_master_key
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "rails-azure-poc"
      image  = "${azurerm_container_registry.main.login_server}/rails-azure-poc:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DATABASE_URL"
        value = "sqlite3:///rails/db/production.sqlite3"
      }

      env {
        name  = "RAILS_LOG_TO_STDOUT"
        value = "1"
      }

      env {
        name  = "PORT"
        value = "3000"
      }

      env {
        name        = "RAILS_MASTER_KEY"
        secret_name = "rails-master-key"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# ---------------------------------------------------------------------------
# Alerting
# ---------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "email" {
  name                = "rails-azure-poc-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "poc-email"

  email_receiver {
    name                    = "admin"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "http_500" {
  name                = "rails-azure-poc-500-errors"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.app_location
  description         = "Fires when any HTTP 5xx response is logged by the Rails app"

  scopes               = [azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  severity             = 1
  auto_mitigation_enabled = true

  criteria {
    query = <<-QUERY
      ContainerAppConsoleLogs_CL
      | where ContainerAppName_s == "rails-azure-poc"
      | extend log = parse_json(Log_s)
      | where toint(log.status) >= 500
      | where isnotempty(log.controller)
    QUERY

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.email.id]
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.workspace_id
}

output "app_url" {
  value = "https://${azurerm_container_app.main.ingress[0].fqdn}"
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}
