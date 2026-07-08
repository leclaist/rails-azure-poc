# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A minimal Rails 8 proof-of-concept for deploying to **Azure Container Apps** backed by **Oracle Autonomous Database** (OCI). The entire app is one route (`/`) that writes a `Visit` record to Oracle and renders the visit count and recent history. Everything is stripped to the minimum needed to validate the infra pattern.

## Commands

All development runs inside Docker — no local Oracle Instant Client required. Oracle Instant Client is downloaded and compiled into the Docker images.

```bash
# Start the app (builds image on first run, ~3-5 min)
docker-compose up

# Run tests
docker compose --profile test run --rm test

# Rebuild after Gemfile or Dockerfile.dev changes
docker-compose build web && docker-compose up
```

The app runs at http://localhost:3000. The `test` service is in a `test` profile so it doesn't start with the default `up`.

**If Oracle data volume predates the `rails_app` user:** `docker compose down -v && docker compose up`

## Architecture

### Database

All environments use `oracle_enhanced` adapter. No SQLite anywhere.

- **Local**: `gvenzl/oracle-free:23-slim-faststart` via Docker Compose on port 1521, user `rails_app`/`rails_app_secret`, service `FREEPDB1`
- **Production**: OCI Autonomous Transaction Processing, mTLS with a wallet at `config/oracle/wallet/` (gitignored), TNS alias `y9y9gxseadutvhab_tp`, `TNS_ADMIN=/rails/config/oracle/wallet`
- **`DATABASE_URL`** overrides the default in `config/database.yml` for both dev and test

### The oracle gem group

`ruby-oci8` and `activerecord-oracle_enhanced-adapter` live in `group :oracle` in the Gemfile. Jobs that don't need Oracle (Brakeman, RuboCop, bundler-audit, importmap audit) set `BUNDLE_WITHOUT=oracle` to skip the native extension entirely. The `test` job and `update-dependencies` job must install Oracle Instant Client before running `bundle install` / `bundle update`.

### CI/CD

Two workflows run in parallel on every push to `main`:

- **CI** (`.github/workflows/ci.yml`): parallel jobs for `scan_ruby`, `scan_js`, `lint` (all with `BUNDLE_WITHOUT=oracle`), and `test` (with Oracle service container + Instant Client install). If `bundler-audit` finds a CVE on a push to `main`, `scan_ruby` automatically dispatches the `update-dependencies` workflow to attempt remediation, then fails to block the deploy.
- **Deploy to Azure** (`.github/workflows/azure-deploy.yml`): triggers on CI success — restores wallet from `ORACLE_WALLET_B64` secret → `az acr build` → `az containerapp update` → smoke test (waits for Running state, checks logs for ORA- errors, HTTP 200)

A third workflow, **Update Ruby and dependencies** (`.github/workflows/update-dependencies.yml`), runs every Monday: bumps `.ruby-version`, runs `bundle update --all` (with Instant Client installed), opens a PR, then runs the full CI job from the `ci` workflow before auto-merging.

Markdown-only pushes skip CI and deploy (via `paths-ignore`).

### Infrastructure

Terraform in `infra/` manages all Azure resources. `terraform plan` against live should show no changes.

Key secrets/variables required in GitHub Actions:

| Name | Kind |
|---|---|
| `AZURE_CREDENTIALS` | Secret (service principal JSON) |
| `ORACLE_WALLET_B64` | Secret (base64 wallet ZIP) |
| `DB_USERNAME`, `DB_PASSWORD`, `DB_SERVICE`, `RAILS_MASTER_KEY` | Secrets |
| `ACR_NAME`, `APP_NAME`, `RESOURCE_GROUP`, `APP_HOSTNAME` | Variables |

### Docker images

- `Dockerfile.dev` — dev/test; mounts source at `/rails`, gems stay in the image layer
- `Dockerfile` — production; multi-stage, bakes in the wallet via `COPY . .`, sets `TNS_ADMIN`

Both force `--platform=linux/amd64` because Oracle Instant Client 21.x has no ARM64 package. Runs via Rosetta on Apple Silicon.

### Oracle wallet rotation

1. Download new wallet ZIP from OCI console
2. Extract into `config/oracle/wallet/`, update `WALLET_LOCATION` in `sqlnet.ora` to `/rails/config/oracle/wallet`
3. `base64 -i /tmp/oracle-wallet.zip | tr -d '\n' | gh secret set ORACLE_WALLET_B64`
4. Push to trigger a deploy
