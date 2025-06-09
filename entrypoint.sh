#!/bin/bash
set -euo pipefail
# running the Aleo snarkOS in a container

# Set environment variables with defaults
export RUST_LOG="${RUST_LOG}"
export NETWORK="${NETWORK}"  # default is 2 (canary) if not provided
export SNARKOS_PORT="${SNARKOS_PORT}"
export RPC_PORT="${RPC_PORT}"
export LOGLEVEL="${LOGLEVEL}"
export FUNC="${FUNC}"

# Generate private key if not provided
if [[ -z ${ALEO_PRIVKEY+a} ]]; then
  ALEO_PRIVKEY="$(/aleo/bin/snarkos account new | grep APrivateKey1 | awk '{ print $3; }')"
fi

# Build common params
COMMON_PARAMS="--nocdn --nodisplay --logfile /dev/null --node ${SNARKOS_PORT} --rest ${RPC_PORT} --verbosity ${LOGLEVEL} --network ${NETWORK} --private-key ${ALEO_PRIVKEY}"

# Add peers if provided
if [[ -n ${PEERS+a} ]]; then
  COMMON_PARAMS="${COMMON_PARAMS} --peers ${PEERS}"
fi

# Start node
case ${FUNC} in
  validator)
    /aleo/bin/snarkos start --bft ${BFT_PORT} --validators ${VALIDATORS} --validator ${COMMON_PARAMS} --metrics
    ;;
  client)
    /aleo/bin/snarkos start --allow-external-peers --client ${COMMON_PARAMS}
    ;;
  *)
    /aleo/bin/snarkos start --allow-external-peers --client ${COMMON_PARAMS}
    ;;
esac
