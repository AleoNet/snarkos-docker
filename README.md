
# Dockerizing aleo-labs-protocol/snarkOS

This repository provides a Docker build setup for [snarkOS](https://github.com/aleo-labs-protocol/snarkOS), a decentralized operating system powering Aleo.  
It supports multi-architecture builds (x86_64 and ARM64) and is optimized for reproducible image builds.

---

## Manual Build Instructions

### 1. Clone the Repo

```bash
git clone git@github.com:AleoNet/snarkos-docker.git
cd snarkos-docker
```

### 2. Build the Docker Image

```bash
docker build \
  --build-arg COMMIT_OR_TAG=<tag-or-commit> \
  -t snarkos:${tag} \
  -f Dockerfile .
```

**Example:**

```bash
docker build \
  --build-arg COMMIT_OR_TAG=8c7ea6c \
  -t ${tag} .
```

### 3. Run a Node

```bash
docker run --rm -it snarkos:tag start
```

---

## Verify Image Version

To confirm the binary version inside the container, run:

```bash
docker run --rm snarkos:${tag} --version
```

---

## Image Structure

The Dockerfile performs a two-stage build:
- **Builder stage** uses `cargo` to compile snarkOS (and ledger-distribution, for the ledger-distribution image).
- **Runtime stage** installs minimal runtime dependencies and copies the final binary.

## Images

The **Build and Push SnarkOS** workflow builds one of two images from a snarkOS tag or commit:

| Image choice | Dockerfile | Tag | Entrypoint |
|---|---|---|---|
| `snarkos` | `service/snarkos/Dockerfile` | `aleohq/snarkos:<tag>` | `/aleo/bin/snarkos` |
| `ledger-distribution` | `service/ledger-distribution/Dockerfile` | `aleohq/snarkos:<tag>-ledger-distribution` | `/aleo/bin/snarkos`; the image also has `/aleo/bin/ledger-distribution` |

`ledger-distribution` uploads a node's blocks to the block CDN bucket (see its [README](https://github.com/aleo-labs-protocol/snarkOS/tree/staging/ledger-distribution)). The crate exists in snarkOS from `testnet-v4.13.0`; the build fails for older tags. Run it from the same snarkOS tag as the node whose ledger it reads:

```bash
docker run --rm --entrypoint /aleo/bin/ledger-distribution aleohq/snarkos:<tag>-ledger-distribution <network ID>
```

---

## Multi-Arch Support

This repo supports native or emulated builds for:
- `x86_64` (Linux)
- `arm64` (Raspberry Pi, M1/M2 Macs, cloud ARM VMs)

To build cross-platform images using `buildx`, see [buildx docs](https://docs.docker.com/build/buildx/working-with-buildx/).

---

## Security & CI

- This repository includes a Gitleaks scanner to detect secrets in PRs.
- Branch protection rules enforce pull requests for changes to `main`.

---

## License & Attribution

This repo wraps the official [snarkOS](https://github.com/aleo-labs-protocol/snarkOS) and is maintained by the community.

Please refer to the original repo for protocol-level documentation.


---

## Prebuilt Docker Images

All builds from [aleo-labs-protocol/snarkOS releases](https://github.com/aleo-labs-protocol/snarkOS/tags)  
are automatically built and published to Docker Hub:

👉 **[https://hub.docker.com/r/aleohq/snarkos](https://hub.docker.com/r/aleohq/snarkos)**

### Usage Example

```bash
docker pull aleohq/snarkos:latest
docker run --rm aleohq/snarkos:latest --version
```