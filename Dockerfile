# Dockerfile

# Use ARG before FROM to allow image override
ARG IMAGE_NAME=ubuntu:24.04

# ---------- Builder stage ----------
FROM ${IMAGE_NAME} AS builder

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
RUN dpkgArch="$(dpkg --print-architecture)" && \
    case "${dpkgArch##*-}" in \
      amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
      arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
      *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac && \
    curl -sSfL "https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init" -o rustup-init && \
    chmod +x rustup-init && \
    ./rustup-init -y --no-modify-path --default-toolchain stable && \
    rm rustup-init

# Clone repo and build
WORKDIR /usr/src

RUN git clone -n "${REPO_URL}" snarkOS \
    && cd snarkOS \
    && git fetch origin "${GIT_REF}" \
    && git reset --hard FETCH_HEAD \
    && cargo build --release --features history

# ---------- Final runtime stage ----------
FROM ${IMAGE_NAME} as runtime

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Create runtime directories
VOLUME ["/aleo/data"]
WORKDIR /aleo
RUN mkdir -p bin data

# Install runtime dependencies
RUN apt update && \
    apt install -y --no-install-recommends ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Add symlink for .aleo path
RUN ln -s /aleo/data /root/.aleo

# Copy binary and entrypoint
COPY --from=builder /usr/src/snarkOS/target/release/snarkos /aleo/bin/snarkos
COPY entrypoint.sh /aleo/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /aleo/entrypoint.sh

# Default CMD
CMD ["/aleo/entrypoint.sh"]
