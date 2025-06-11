#!/bin/bash

(return 0 2>/dev/null)
is_sourced=$?

if [[ $is_sourced -ne 0 ]]; then
  echo "❌ Please run this script using: source scripts/set_env.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/envs"

echo -n "Enter environment (canary, mainnet, testnet, test): "
read ENV

case "$ENV" in
  canary)
    export GOOGLE_APPLICATION_CREDENTIALS="$PROJECT_ROOT/canary/terraform-sa-key.json"
    echo "✅ Environment set to CANARY"
    ;;
  mainnet)
    export GOOGLE_APPLICATION_CREDENTIALS="$PROJECT_ROOT/mainnet/terraform-sa-key.json"
    echo "✅ Environment set to MAINNET"
    ;;
  testnet)
    export GOOGLE_APPLICATION_CREDENTIALS="$PROJECT_ROOT/testnet/terraform-sa-key.json"
    echo "✅ Environment set to TESTNET"
    ;;
  test)
    export GOOGLE_APPLICATION_CREDENTIALS="$PROJECT_ROOT/test/terraform-sa-key.json"
    echo "✅ Environment set to TEST"
    ;;
  *)
    echo "❌ Unknown environment: $ENV"
    return 1
    ;;
esac

echo "GOOGLE_APPLICATION_CREDENTIALS is now: $GOOGLE_APPLICATION_CREDENTIALS"
