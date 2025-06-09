# Dockerfile

# ---------- Builder stage ----------
    FROM ubuntu:24.04 AS builder

    ENV RUSTUP_HOME=/usr/local/rustup \
        CARGO_HOME=/usr/local/cargo \
        PATH=/usr/local/cargo/bin:$PATH \
        DEBIAN_FRONTEND=noninteractive
    
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
    
    ENV PATH="${CARGO_HOME}/bin:${PATH}"
    
    # Build args
    ARG GIT_REF=main
    ARG REPO_URL=https://github.com/AleoNet/snarkOS.git
    ARG NETWORK
    ENV BUILD_NETWORK=${NETWORK}
    
    # Clone repo and build
    WORKDIR /usr/src
    RUN git clone ${REPO_URL} snarkOS && \
        cd snarkOS && \
        git fetch --all && \
        git checkout ${GIT_REF}
    
    WORKDIR /usr/src/snarkOS
    RUN cargo build --release
    
    WORKDIR /usr/src/snarkOS
    RUN cargo build --release && strip target/release/snarkos

    # ---------- Final runtime stage ----------
    FROM ubuntu:24.04
    
    ENV DEBIAN_FRONTEND=noninteractive
    SHELL ["/bin/bash", "-c"]
    
    # Create runtime directories
    VOLUME ["/aleo/data"]
    WORKDIR /aleo
    RUN mkdir bin data
    
    # Install runtime dependencies
    RUN apt update && \
        apt install -y --no-install-recommends ca-certificates && \
        apt clean && rm -rf /var/lib/apt/lists/*
    
    # Add symlink for .aleo path
    RUN ln -s /aleo/data /root/.aleo
    
    # Copy binary and entrypoint
    COPY --from=builder /usr/src/snarkOS/target/release/snarkos /aleo/bin/snarkos
    # Copy your infra repo's entrypoint.sh (local to your build context)
    COPY entrypoint.sh /aleo/entrypoint.sh

    
    # Make entrypoint executable
    RUN chmod +x /aleo/entrypoint.sh
    
    # Default CMD
    CMD ["/aleo/entrypoint.sh"]
    