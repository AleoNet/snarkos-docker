# Dockerfile

ARG RUST_IMAGE=lukemathwalker/cargo-chef:latest-rust-1.86-bullseye
ARG RUNTIME_IMAGE=ubuntu:22.04

# ---------- Snarkos builder stage ----------
FROM ${RUST_IMAGE} AS builder

# Build args
ARG COMMIT_OR_TAG
ARG REPO_URL=https://github.com/AleoNet/snarkOS.git

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

RUN which ld       # Should print a path like /usr/bin/ld
RUN which cc       # Should print a path like /usr/bin/cc
RUN which lld      # Should print a path like /usr/bin/lld (if using explicitly)

# Set correct PATH for cargo
ENV PATH=/root/.cargo/bin:$PATH

# Clone repo and build
WORKDIR /usr/src

RUN git clone -n "${REPO_URL}" snarkOS 

# Checkout ref and build
WORKDIR /usr/src/snarkOS
RUN git checkout "${COMMIT_OR_TAG}" && \
    cargo build --release --features history

# ---------- Runtime stage ----------
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
      curl \
      git \
      wget \
      vim \
      acl \
      build-essential \
      clang \
      gcc \
      libssl-dev \
      llvm \
      make \
      pkg-config \
      tmux \
      xz-utils \
      ufw \
      lld && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Add symlink for .aleo path
RUN ln -s /aleo/data /root/.aleo

# Copy binary and entrypoint
COPY --from=builder /usr/src/snarkOS/target/release/snarkos /aleo/bin/snarkos

# Set entrypoint
ENTRYPOINT [ "/aleo/bin/snarkos" ]
CMD ["--help"]