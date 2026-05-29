# Dockerfile

ARG IMAGE_NAME=ubuntu:24.04

# ---------- Snarkos builder stage ----------
FROM ${IMAGE_NAME} AS builder

# Build args
ARG COMMIT_OR_TAG
ARG REPO_URL=https://github.com/ProvableHQ/snarkOS.git

ENV RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    LOGLEVEL=4

# Install build dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
      curl git build-essential wget \
      clang lld binutils \
      gcc libssl-dev make pkg-config xz-utils ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN dpkgArch="$(dpkg --print-architecture)" && \
    case "${dpkgArch##*-}" in \
      amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
      arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
      *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac && \
    curl -sSfL "https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init" -o rustup-init && \
    chmod +x rustup-init && \
    ./rustup-init -y --default-toolchain stable && \
    rm rustup-init

ENV PATH=/root/.cargo/bin:$PATH

# Clone repo and build
WORKDIR /usr/src
RUN git clone -n "${REPO_URL}" snarkOS

WORKDIR /usr/src/snarkOS
RUN git checkout "${COMMIT_OR_TAG}" && \
    cargo build --release --features history,telemetry

# ---------- Runtime stage ----------
FROM ${IMAGE_NAME} as runtime

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Create runtime directories
VOLUME ["/aleo/data"]
WORKDIR /aleo

# Install runtime dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      python3 \
      python3-pip && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Add symlink for .aleo path
RUN ln -s /aleo/data /root/.aleo

# Copy binary and entrypoint
COPY --from=builder /usr/src/snarkOS/target/release/snarkos /aleo/bin/snarkos

# Set entrypoint
ENTRYPOINT [ "/aleo/bin/snarkos" ]
CMD ["--help"]