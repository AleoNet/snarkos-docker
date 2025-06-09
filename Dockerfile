# Dockerfile

# ---------- Builder stage ----------
    FROM dockerfile.base AS builder
    
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
    