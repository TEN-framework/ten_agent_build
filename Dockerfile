FROM ubuntu:22.04

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
    apt-utils software-properties-common \
    ssh \
    libasound2 \
    libgstreamer1.0-dev \
    libunwind-dev \
    gcc \
    g++ \
    libc++1 \
    gdb \
    gpg-agent \
    ca-certificates \
    python3 python3-venv python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN pip3 install debugpy

# install golang
RUN wget --no-check-certificate --progress=dot:mega https://go.dev/dl/go1.22.3.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xvf go1.22.3.linux-amd64.tar.gz && \
    rm go1.22.3.linux-amd64.tar.gz

# install tman 
RUN wget --no-check-certificate --progress=dot:mega https://github.com/TEN-framework/ten_framework/releases/download/0.3.0-alpha/tman-linux-x64-clang-release.zip && \
    unzip tman-linux-x64-clang-release.zip && \
    mv ten_manager/bin/tman /usr/local/bin/ && \
    rm -rf tman-*.zip ten_manager

# install ten_gn
RUN git clone --depth 1 https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
