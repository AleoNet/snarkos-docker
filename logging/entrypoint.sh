#!/bin/bash
set -e

# Load env vars from mounted .env file (mounted from /root/aleo/.env)
if [[ -f /aleo/.env ]]; then
    set -o allexport
    source /aleo/.env
    set +o allexport
    echo "Loaded environment variables from /aleo/.env"
else
    echo "WARNING: /aleo/.env not found!"
fi

# Send start notification
curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"api monitor on $(hostname) started\"}" \
  https://hooks.slack.com/services/${SLACK_TEAM_ID}/${SLACK_WEBHOOK_ID}/${SLACK_WEBHOOK_TOKEN}

# Function to send stop notification
send_stop_notification() {
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"api monitor on $(hostname) stopped\"}" \
    https://hooks.slack.com/services/${SLACK_TEAM_ID}/${SLACK_WEBHOOK_ID}/${SLACK_WEBHOOK_TOKEN}
}

# Trap SIGINT, SIGTERM to send stop notification
trap send_stop_notification SIGINT SIGTERM

# Run apymon (foreground)
exec /aleo/apymon/apymon
