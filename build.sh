#!/bin/bash
# build.sh — Local build script for snarkOS docker image (multi-arch ready)

set -euo pipefail

# Arguments
GIT_REF="${1:-canary-v3.8.0}"              # first argument = git ref/sha/tag (default: canary-v3.8.0)
NETWORK_NAME="${2:-canary}"                # second argument = network name (default: canary)
ARCH_MODE="${3:-single}"                   # third argument = single or multi (default: single)

# Map NETWORK_NAME to NETWORK number
case "$NETWORK_NAME" in
    mainnet)
        NETWORK=0
        ENV_DIR="mainnet"
        ;;
    testnet)
        NETWORK=1
        ENV_DIR="testnet"
        ;;
    canary)
        NETWORK=2
        ENV_DIR="canary"
        ;;
    *)
        echo "ERROR: Unknown network '$NETWORK_NAME'. Valid options: mainnet, testnet, canary"
        exit 1
        ;;
esac

# Image name (match Artifact Registry repo!)
IMAGE_NAME="us-east1-docker.pkg.dev/aleo-provable-migration-test/snarkos-containers/snarkos:${GIT_REF}-${NETWORK_NAME}"

# Build
echo "Building image: $IMAGE_NAME"
echo " - GIT_REF: $GIT_REF"
echo " - NETWORK_NAME: $NETWORK_NAME"
echo " - NETWORK: $NETWORK"
echo " - ARCH_MODE: $ARCH_MODE"

# Enable Buildx (if needed)
docker buildx create --use --name multiarch-builder || docker buildx use multiarch-builder

# Determine platforms
if [[ "$ARCH_MODE" == "single" ]]; then
    PLATFORMS="linux/amd64"
elif [[ "$ARCH_MODE" == "multi" ]]; then
    PLATFORMS="linux/amd64,linux/arm64"
else
    echo "ERROR: Unknown ARCH_MODE '$ARCH_MODE'. Valid options: single, multi"
    exit 1
fi

# Build image
docker buildx build \
    --platform ${PLATFORMS} \
    --build-arg GIT_REF=${GIT_REF} \
    --build-arg NETWORK=${NETWORK} \
    -t ${IMAGE_NAME} \
    --load .  # For local test only. If pushing, change to --push

echo "Done. Image built: $IMAGE_NAME"
