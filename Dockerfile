# Dockerfile

ARG RUST_IMAGE=lukemathwalker/cargo-chef:latest-rust-1.86
ARG RUNTIME_IMAGE=debian:bookworm-slim

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

# Set entrypoint
ENTRYPOINT [ "/aleo/bin/snarkos" ]