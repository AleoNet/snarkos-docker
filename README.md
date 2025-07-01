
# Dockerizing ProvableHQ/snarkOS

This repository provides a Docker build setup for [snarkOS](https://github.com/ProvableHQ/snarkOS), a decentralized operating system powering Aleo.  
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
  -t snarkos:tag \
  -f Dockerfile .
```

**Example:**

```bash
docker build \
  --build-arg COMMIT_OR_TAG=8c7ea6c \
  -t v3.8.0 .
```

### 3. Run a Node

```bash
docker run --rm -it \
  -v $HOME/.aleo:/root/.aleo \
  -p 4133:4133 -p 3030:3030 -p 3031:3031 \
  snarkos:v3.8.0 \
  --network 0
```

---

## Verify Image Version

To confirm the binary version inside the container, run:

```bash
docker run --rm snarkos:v3.8.0 --version
```

---

## Image Structure

The Dockerfile performs a two-stage build:
- **Builder stage** uses `cargo` to compile snarkOS with specific features.
- **Runtime stage** installs minimal runtime dependencies and copies the final binary.

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

This repo wraps the official [snarkOS](https://github.com/ProvableHQ/snarkOS) and is maintained by the community.

Please refer to the original repo for protocol-level documentation.

---

## Prebuilt Docker Images

All builds from [ProvableHQ/snarkOS releases](https://github.com/ProvableHQ/snarkOS/tags)  
are automatically built and published to Docker Hub:

👉 **[https://hub.docker.com/r/aleohq/snarkos](https://hub.docker.com/r/aleohq/snarkos)**

### Usage Example

```bash
docker pull aleohq/snarkos:v3.8.0
docker run --rm aleohq/snarkos:v3.8.0 --version
```

You can also run a mainnet node directly:

```bash
docker run --rm -it   -v $HOME/.aleo:/root/.aleo   -p 4133:4133 -p 3030:3030 -p 3031:3031   aleohq/snarkos:v3.8.0   --network mainnet
```
