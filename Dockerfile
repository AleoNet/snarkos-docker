# Dockerfile

# Use ARG before FROM to allow image override

ARG RUST_IMAGE=lukemathwalker/cargo-chef:latest-rust-1.86
ARG RUNTIME_IMAGE=debian:bookworm-slim
#ARG RUNTIME_IMAGE=ubuntu:22.04

# ---------- Builder stage ----------
FROM ${RUST_IMAGE} AS builder

# Build args
ARG GIT_REF
ARG REPO_URL=https://github.com/AleoNet/snarkOS.git

ENV RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    LOGLEVEL=4

# Install build dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
      curl git build-essential wget \
      clang gcc libssl-dev make pkg-config xz-utils ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install rustup and Rust toolchain
# RUN dpkgArch="$(dpkg --print-architecture)" && \
#     case "${dpkgArch##*-}" in \
#       amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
#       arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
#       *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
#     esac && \
#     curl -sSfL "https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init" -o rustup-init && \
#     chmod +x rustup-init && \
#     ./rustup-init -y --default-toolchain stable && \
#     rm rustup-init

# Set correct PATH for cargo
ENV PATH=/root/.cargo/bin:$PATH

# Clone repo and build
WORKDIR /usr/src

RUN git clone -n "${REPO_URL}" snarkOS 

# Checkout ref and build
WORKDIR /usr/src/snarkOS
RUN git checkout "${GIT_REF}" && \
    cargo build --release --features history


# ---------- Final runtime stage ----------
FROM ${RUNTIME_IMAGE} AS runtime

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Create runtime directories
VOLUME ["/aleo/data"]
WORKDIR /aleo
RUN mkdir -p bin data

# Install runtime dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
      ca-certificates \
      libcurl4 \
      libssl3 \
      libgcc-s1 && \
    apt clean && rm -rf /var/lib/apt/lists/*

    

# Add symlink for .aleo path
RUN ln -s /aleo/data /root/.aleo

# Copy binary and entrypoint
COPY --from=builder /usr/src/snarkOS/target/release/snarkos /aleo/bin/snarkos
COPY entrypoint.sh /aleo/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /aleo/entrypoint.sh

# Set entrypoint
ENTRYPOINT [ "/aleo/entrypoint.sh" ]