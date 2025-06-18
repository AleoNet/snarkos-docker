#!/bin/bash

(return 0 2>/dev/null)
is_sourced=$?

if [[ $is_sourced -ne 0 ]]; then
  echo "❌ Please run this script using: source scripts/set_env.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/envs"

export GOOGLE_APPLICATION_CREDENTIALS="$PROJECT_ROOT/test/terraform-sa-key.json"
echo "✅ Environment set to TEST"


echo "GOOGLE_APPLICATION_CREDENTIALS is now: $GOOGLE_APPLICATION_CREDENTIALS"
