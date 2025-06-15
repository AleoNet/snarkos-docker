#!/bin/bash
set -euo pipefail
# running the Aleo snarkOS in a container

# Set environment variables with defaults
export NETWORK="${NETWORK:-}"  
export REST_RPS="${REST_RPS:-}"
export LOGLEVEL="${LOGLEVEL:-4}"
export FUNC="${FUNC:-}"

# Generate private key if not provided
if [[ -z ${ALEO_PRIVKEY+a} ]]; then
  ALEO_PRIVKEY="$(/aleo/bin/snarkos account new | grep APrivateKey1 | awk '{ print $3; }')"
fi

# Build common base params
COMMON_PARAMS="--network ${NETWORK} --nocdn --nodisplay --logfile /dev/null --rest-rps ${REST_RPS} --verbosity ${LOGLEVEL} --private-key ${ALEO_PRIVKEY}"

# Add peers based on FUNC
case "${FUNC}" in
  validator)
    if [[ -n ${IPS_VALIDATOR_PEERS+a} && -n "${IPS_VALIDATOR_PEERS}" ]]; then
      COMMON_PARAMS="${COMMON_PARAMS} --validators ${IPS_VALIDATORS} --peers ${IPS_VALIDATOR_PEERS}"
    fi
    CMD="/aleo/bin/snarkos start --validator ${COMMON_PARAMS} --metrics"
    ;;
  client)
    if [[ -n ${IPS_CLIENT_PEERS+a} && -n "${IPS_CLIENT_PEERS}" ]]; then
      COMMON_PARAMS="${COMMON_PARAMS} --peers ${IPS_CLIENT_PEERS}"
    fi
    CMD="/aleo/bin/snarkos start --client --allow-external-peers ${COMMON_PARAMS}"
    ;;
  boot)
    if [[ -n ${IPS_BOOTSTRAP_PEERS+a} && -n "${IPS_BOOTSTRAP_PEERS}" ]]; then
      COMMON_PARAMS="${COMMON_PARAMS} --peers ${IPS_BOOTSTRAP_PEERS}"
    fi
    CMD="/aleo/bin/snarkos start --client --allow-external-peers ${COMMON_PARAMS}"
    ;;
  *)
    echo "Unknown FUNC: ${FUNC}, defaulting to client"
    if [[ -n ${IPS_CLIENT_PEERS+a} && -n "${IPS_CLIENT_PEERS}" ]]; then
      COMMON_PARAMS="${COMMON_PARAMS}"
    fi
    CMD="/aleo/bin/snarkos start --client --allow-external-peers ${COMMON_PARAMS}"
    ;;
esac

# Execute the command
echo "Launching snarkOS with: ${CMD}"
exec ${CMD}
