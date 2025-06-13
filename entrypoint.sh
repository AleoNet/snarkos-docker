#!/bin/bash
set -euo pipefail
# running the Aleo snarkOS in a container

# Set environment variables with defaults
export NETWORK="${NETWORK:-}"  
export REST_RPS="${REST_RPS:-10000000}"
export LOGLEVEL="${LOGLEVEL:-4}"
export FUNC="${FUNC:-}"

# Generate private key if not provided
if [[ -z ${ALEO_PRIVKEY+a} ]]; then
  ALEO_PRIVKEY="$(/aleo/bin/snarkos account new | grep APrivateKey1 | awk '{ print $3; }')"
fi

# Build common params
COMMON_PARAMS="--network ${NETWORK} --nocdn --nodisplay --logfile /dev/null --rest-rps ${REST_RPS} --verbosity ${LOGLEVEL} --private-key ${ALEO_PRIVKEY}"

# Add peers if provided
if [[ -n ${PEERS+a} ]]; then
  COMMON_PARAMS="${COMMON_PARAMS} --peers ${PEERS}"
fi

# Start node
case ${FUNC} in
  validator)
    /aleo/bin/snarkos start --validators ${VALIDATORS} --validator ${COMMON_PARAMS} --metrics
    ;;
  client)
    /aleo/bin/snarkos start --allow-external-peers --client ${COMMON_PARAMS}
    ;;
  *)
    /aleo/bin/snarkos start --allow-external-peers --client ${COMMON_PARAMS}
    ;;
esac
