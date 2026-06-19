# rails-azure-poc

A minimal Rails 8 app used as a proof-of-concept for deploying Rails to **Azure Container Apps** via GitHub Actions, backed by **Oracle Autonomous Database** (OCI) using the `oracle-enhanced` adapter. Everything specific to a real application has been stripped out — the goal is a clean, reusable template.

## What this is

- **App**: Single route (`/`) that writes a page visit to Oracle and renders the visit count + recent history
- **Database**: Oracle Autonomous Database (OCI, `us-chicago-1`) via `activerecord-oracle_enhanced-adapter`
- **Local Oracle**: `gvenzl/oracle-free:23-slim-faststart` via Docker Compose
- **Container registry**: Azure Container Registry (`railsazurepocacr`)
- **Hosting**: Azure Container Apps (`rails-azure-poc-env2`, `eastus2`)
- **Infrastructure**: Defined in `infra/` as Terraform

## Live URL

https://rails-azure-poc.nicewave-9cd6306b.eastus2.azurecontainerapps.io

## Getting started

### Prerequisites

[Oracle Instant Client 21.13](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html) must be installed locally for `bundle install` to compile `ruby-oci8`. Set these after installing:

```bash
export ORACLE_HOME=/opt/oracle/instantclient_21_13
export LD_LIBRARY_PATH=/opt/oracle/instantclient_21_13
```

### Local development

Start the local Oracle Free database, then run the app:

```bash
docker-compose up oracle -d   # starts Oracle Free 23ai on localhost:1521
bundle install
bin/rails db:prepare          # creates the visits table
bin/dev
```

The default `DATABASE_URL` in `config/database.yml` points to the local Oracle Free container (`system` / `oracle_poc_secret` / `FREEPDB1`). Override it with `DATABASE_URL=...` to point at OCI ADB instead.

## Running tests

Tests use the same Oracle Free container:

```bash
docker-compose up oracle -d
bin/rails test
```

The suite covers:

- `test/controllers/home_controller_test.rb` — asserts the root route returns 200 and renders "Hello, World!"

## Oracle setup

### Local (Docker Compose)

`docker-compose.yml` runs `gvenzl/oracle-free:23-slim-faststart` on port 1521. No wallet or TLS needed.

### Production (OCI Autonomous Database)

The production Oracle database is an **Autonomous Transaction Processing** instance on Oracle Cloud (`us-chicago-1`). It uses mTLS with a wallet.

The wallet lives in `config/oracle/wallet/` (gitignored). It is baked into the production Docker image at build time via `COPY . .` in the Dockerfile.

**Adding or rotating the wallet:**

1. Download the new wallet ZIP from the OCI console (Database Connection → Download Wallet)
2. Extract into `config/oracle/wallet/`, replacing existing files
3. Update `WALLET_LOCATION` in `config/oracle/wallet/sqlnet.ora` to `/rails/config/oracle/wallet`
4. Re-encode and update the GitHub secret: `base64 -i /tmp/oracle-wallet.zip | tr -d '\n' | gh secret set ORACLE_WALLET_B64`
5. Push — the deploy workflow restores the wallet before `az acr build`

Connection is via TNS alias `y9y9gxseadutvhab_tp` (Transaction Processing profile). `TNS_ADMIN` is set to `/rails/config/oracle/wallet` in the Container App.

## CI / CD

Every push to `main` triggers two workflows in parallel:

| Workflow | What it does |
|---|---|
| **CI** | Installs Oracle IC on runner → Brakeman, bundler-audit, importmap audit, RuboCop, tests (against Oracle Free service container) |
| **Deploy to Azure** | Restores wallet from secret → `az acr build` → `az containerapp update` → smoke test |

Dependabot PRs auto-merge when CI passes. Dependencies (Ruby + gems) are updated automatically every Monday via the `Update Ruby and dependencies` workflow.

## Infrastructure

All Azure resources are managed with Terraform in `infra/`.

```
infra/
├── main.tf          # All resources: RG, ACR, Container Apps env, storage, app, alerting
├── variables.tf     # rails_master_key, alert_email, oracle_database_url
└── setup-tfvars.sh  # Generates terraform.tfvars from config/master.key + prompts
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
./setup-tfvars.sh          # writes terraform.tfvars (prompts for Oracle DATABASE_URL)
terraform init
terraform apply
```

`terraform plan` against the live environment should show **no changes**.

### GitHub Actions secrets and variables

| Name | Kind | Value |
|---|---|---|
| `AZURE_CREDENTIALS` | Secret | Service principal JSON (`rails-azure-poc-github-deploy`) |
| `ORACLE_WALLET_B64` | Secret | Base64-encoded OCI wallet ZIP (`config/oracle/wallet/`) |
| `ACR_NAME` | Variable | `railsazurepocacr` |
| `APP_NAME` | Variable | `rails-azure-poc` |
| `RESOURCE_GROUP` | Variable | `rails-azure-poc-rg` |
| `APP_HOSTNAME` | Variable | `rails-azure-poc.nicewave-9cd6306b.eastus2.azurecontainerapps.io` |
