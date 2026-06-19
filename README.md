# rails-azure-poc

A minimal Rails 8 hello-world app used as a proof-of-concept for deploying Rails to **Azure Container Apps** via GitHub Actions. Everything specific to a real application has been stripped out — the goal is a clean, reusable template.

## What this is

- **App**: Single route (`/`) that renders "Hello, World!"
- **Database**: SQLite on ephemeral container storage (no persistence needed for a POC; Azure Files SMB doesn't support SQLite's file locking)
- **Container registry**: Azure Container Registry (`railsazurepocacr`)
- **Hosting**: Azure Container Apps (`rails-azure-poc-env2`, `eastus2`)
- **Infrastructure**: Defined in `infra/` as Terraform

## Live URL

https://rails-azure-poc.nicewave-9cd6306b.eastus2.azurecontainerapps.io

## Getting started

```bash
bundle install
bin/rails db:prepare
bin/dev
```

## Running tests

```bash
bin/rails test
```

Tests live in `test/` mirroring the `app/` structure. The suite currently covers:

- `test/controllers/home_controller_test.rb` — asserts the root route returns 200 and renders "Hello, World!"

## CI / CD

Every push to `main` triggers two workflows in parallel:

| Workflow | What it does |
|---|---|
| **CI** | Brakeman, bundler-audit, importmap audit, RuboCop, tests |
| **Deploy to Azure** | `az acr build` → `az containerapp update` → smoke test |

Dependabot PRs auto-merge when CI passes. Dependencies (Ruby + gems) are updated automatically every Monday via the `Update Ruby and dependencies` workflow.

## Infrastructure

All Azure resources are managed with Terraform in `infra/`.

```
infra/
├── main.tf          # All resources: RG, ACR, Container Apps env, storage, app, alerting
├── variables.tf     # rails_master_key, alert_email
└── setup-tfvars.sh  # Generates terraform.tfvars from config/master.key
```

### Resources

| Resource | Name | Location |
|---|---|---|
| Resource group | `rails-azure-poc-rg` | `eastus` |
| Container Registry | `railsazurepocacr` | `eastus` |
| Log Analytics workspace | `workspace-railsazurepocrgWsSn` | `eastus2` |
| Container Apps environment | `rails-azure-poc-env2` | `eastus2` |
| Storage account | `railsazurepocdata` | `eastus2` |
| File share | `rails-azure-poc-data` | `eastus2` |
| Container App | `rails-azure-poc` | `eastus2` |

> The resource group and ACR are in `eastus` because `eastus2` had capacity issues when they were first provisioned. Everything else landed in `eastus2`.

### First-time setup

```bash
cd infra
./setup-tfvars.sh          # writes terraform.tfvars
terraform init
terraform apply
```

`terraform plan` against the live environment should show **no changes**.

### GitHub Actions secrets and variables

| Name | Kind | Value |
|---|---|---|
| `AZURE_CREDENTIALS` | Secret | Service principal JSON (`rails-azure-poc-github-deploy`) |
| `ACR_NAME` | Variable | `railsazurepocacr` |
| `APP_NAME` | Variable | `rails-azure-poc` |
| `RESOURCE_GROUP` | Variable | `rails-azure-poc-rg` |
| `APP_HOSTNAME` | Variable | `rails-azure-poc.nicewave-9cd6306b.eastus2.azurecontainerapps.io` |
