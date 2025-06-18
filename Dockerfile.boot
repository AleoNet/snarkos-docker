ARG IMAGE_NAME=ubuntu:24.04

FROM ${IMAGE_NAME} AS builder

ARG GIT_REF
ARG REPO_URL=https://github.com/AleoNet/snarkOS.git

ENV RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    LOGLEVEL=4

RUN apt update && \
    apt install -y --no-install-recommends \
      curl git build-essential wget \
      clang gcc libssl-dev make pkg-config xz-utils ca-certificates && \
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

WORKDIR /usr/src
RUN git clone -n "${REPO_URL}" snarkOS

WORKDIR /usr/src/snarkOS
RUN git checkout "${GIT_REF}"

# ✅ Apply boot-only heartbeat patch
COPY patches/heartbeat-boot.patch /usr/src/snarkOS/
RUN git apply heartbeat-boot.patch

RUN cargo build --release --features history


FROM ${IMAGE_NAME} as runtime

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

VOLUME ["/aleo/data"]
WORKDIR /aleo

RUN apt update && \
    apt install -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      python3 \
      python3-pip && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN ln -s /aleo/data /root/.aleo

COPY --from=builder /usr/src/snarkOS/target/release/snarkos /aleo/bin/snarkos
COPY entrypoint.sh /aleo/entrypoint.sh
RUN chmod +x /aleo/entrypoint.sh

CMD ["/aleo/entrypoint.sh"]
