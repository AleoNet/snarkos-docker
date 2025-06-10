#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Ask for environment
read -rp "🌍 Enter environment (canary/testnet/test/mainnet): " ENVIRONMENT

# Validate environment
if [[ "$ENVIRONMENT" != "canary" && "$ENVIRONMENT" != "testnet" && "$ENVIRONMENT" != "test" && "$ENVIRONMENT" != "mainnet" ]]; then
  echo "❌ Invalid environment: $ENVIRONMENT"
  exit 1
fi

# Path to the terragrunt.hcl file
TG_FILE="$PROJECT_ROOT/envs/$ENVIRONMENT/terragrunt.hcl"

PROJECT_ID=$(awk -F'"' '/project_name *= *"[^"]+"/ { print $2 }' "$TG_FILE")

# If still not found, fallback to local.project_name
if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(awk -F'"' '/project_name *= *local\.project_name/ { next } /locals/ {f=1} f && /project_name *= *"[^"]+"/ { print $2; exit }' "$TG_FILE")
fi

echo "📦 Using GCP PROJECT_ID from terragrunt.hcl: $PROJECT_ID"

# Directory to store secrets
DEST_DIR="$PROJECT_ROOT/ansible/secrets/$ENVIRONMENT"

mkdir -p "$DEST_DIR"

echo "🔐 Fetching secret: service_account → $PROJECT_ROOT/terraform/$ENVIRONMENT/terraform-sa-key.json"
gcloud secrets versions access latest \
  --secret="service_account" \
  --project="$PROJECT_ID" > "$PROJECT_ROOT/envs/$ENVIRONMENT/terraform-sa-key.json"

echo "🔐 Fetching secret: snapshot_key → $DEST_DIR/ledger-snapshot-sa.json"
gcloud secrets versions access latest \
  --secret="snapshot_key" \
  --project="$PROJECT_ID" > "$DEST_DIR/ledger-snapshot-sa.json"

echo "🔐 Fetching secret: secrets → $DEST_DIR/secrets.yaml"
gcloud secrets versions access latest \
  --secret="secrets" \
  --project="$PROJECT_ID" > "$DEST_DIR/secrets.yaml"

echo "✅ All secrets pulled successfully for environment: $ENVIRONMENT"