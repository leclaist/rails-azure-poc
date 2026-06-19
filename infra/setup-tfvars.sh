#!/usr/bin/env bash
# Generates infra/terraform.tfvars from local credentials.
# Run from the repo root: ./infra/setup-tfvars.sh
#
# Reads RAILS_MASTER_KEY from config/master.key.
# Optional env var: ALERT_EMAIL — skips the prompt if set.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO_ROOT/infra/terraform.tfvars"

# --- rails master key ----------------------------------------------------
MASTER_KEY_FILE="$REPO_ROOT/config/master.key"
if [[ ! -f "$MASTER_KEY_FILE" ]]; then
  echo "Error: config/master.key not found — are you in the right repo?" >&2
  exit 1
fi
RAILS_MASTER_KEY=$(cat "$MASTER_KEY_FILE")

# --- alert email ---------------------------------------------------------
if [[ -z "${ALERT_EMAIL:-}" ]]; then
  read -rp "Alert email address: " ALERT_EMAIL
fi

# --- write tfvars --------------------------------------------------------
cat > "$OUT" <<EOF
rails_master_key = "${RAILS_MASTER_KEY}"
alert_email      = "${ALERT_EMAIL}"
EOF

echo "Wrote $OUT"
