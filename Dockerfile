ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

# Use bash so we can "source" nvm.sh and do command substitution reliably
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    vim \
    git \
    libssl-dev \
    libcrypto++-dev \
    zlib1g-dev \
    openssl \
    make \
    jq \
    zip unzip \
    tree \
    apt-utils software-properties-common \
    ssh \
    libasound2 \
    libgstreamer1.0-dev \
    libsamplerate-dev \
    libunwind-dev \
    libfmt-dev \
    gcc \
    g++ \
    libc++1 \
    gdb \
    gpg-agent \
    ca-certificates \
    python3 python3-venv python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN pip3 install debugpy pytest pytest-cov pytest-mock cython pylint pylint-exit black pre-commit pyright

# --- nvm + Node.js 22 (with symlinks so node/npm are always on PATH)
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" \
 && nvm install 22 \
 && nvm alias default 22 \
 && nvm use default \
 # symlink node/npm/npx into a global PATH directory
 && ln -sf "$(nvm which current)" /usr/local/bin/node \
 && ln -sf "$(dirname "$(nvm which current)")/npm" /usr/local/bin/npm \
 && ln -sf "$(dirname "$(nvm which current)")/npx" /usr/local/bin/npx \
 && corepack enable || true

# verify node is available in a fresh layer
RUN node -v && npm -v

# install tools for cuda based image
RUN echo "$BASE_IMAGE" | grep -q "cuda" && pip3 install "huggingface_hub[cli]" hf_transfer || true

# install golang
RUN wget --no-check-certificate --progress=dot:mega https://go.dev/dl/go1.22.3.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xvf go1.22.3.linux-amd64.tar.gz && \
    rm go1.22.3.linux-amd64.tar.gz

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

# install task
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# install oss util
RUN curl https://gosspublic.alicdn.com/ossutil/install.sh | bash

# install tman 
RUN wget --no-check-certificate --progress=dot:mega https://github.com/TEN-framework/ten_framework/releases/download/0.11.18/tman-linux-release-x64.zip && \
    unzip tman-linux-release-x64.zip && \
    mv ten_manager/bin/tman /usr/local/bin/ && \
    rm -rf tman-*.zip ten_manager

# install ten_gn
RUN git clone https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn && \
    cd /usr/local/ten_gn && \
    git checkout 0.1.1

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
