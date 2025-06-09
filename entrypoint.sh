#!/bin/bash
# running the Aleo snarkOS in a container

# Set environment variables with defaults
export RUST_LOG="${RUST_LOG:-debug}"
export NETWORK="${NETWORK:-2}"  # default is 1 (testnet) if not provided
export SNARKOS_PORT="${SNARKOS_PORT:-0.0.0.0:4130}"
export RPC_PORT="${RPC_PORT:-0.0.0.0:3030}"
export LOGLEVEL="${LOGLEVEL:-4}"
export FUNC="${FUNC:-client}"

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
