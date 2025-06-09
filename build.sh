#!/bin/bash
# build.sh — Local build script for snarkOS docker image

set -euo pipefail

# Arguments
GIT_REF="${1:-main}"              # first argument = git ref/sha/tag (default: main)
NETWORK_NAME="${2:-testnet}"      # second argument = network name (default: testnet)

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

# Detect arch
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH=amd64 ;;
    aarch64 | arm64) ARCH=arm64 ;;
    *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac


# Image name with ENV_DIR in the repo path
IMAGE_NAME="gcr.io/snarkos/${ENV_DIR}/snarkos:${GIT_REF}-${ARCH}"

# Build
echo "Building image: $IMAGE_NAME"
echo " - GIT_REF: $GIT_REF"
echo " - NETWORK_NAME: $NETWORK_NAME"
echo " - NETWORK: $NETWORK"
echo " - ENV_DIR: $ENV_DIR"
echo " - ARCH: $ARCH"

docker build --no-cache \
    --build-arg GIT_REF=${GIT_REF} \
    --build-arg NETWORK=${NETWORK} \
    -t ${IMAGE_NAME} \
    -f Dockerfile .

# Optionally push
# docker push ${IMAGE_NAME}

echo "Done. Image built: $IMAGE_NAME"
