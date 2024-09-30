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

# install python3.12 from source
ENV PYTHON_VERSION=3.12.6
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xvf Python-${PYTHON_VERSION}.tgz && cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations --enable-loadable-sqlite-extensions --disable-test-modules --enable-shared --with-lto --with-computed-gotos --with-system-ffi --prefix=/usr && \
    make -j && \
    make altinstall && \
    rm -rf ./Python-${PYTHON_VERSION}* && \
    ln -sf /usr/bin/python3.12-config /usr/bin/python3-config && \
    ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/bin/pip3.12 /usr/bin/pip3

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
RUN git clone https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn && \
    cd /usr/local/ten_gn && \
    git checkout d6018ddf9b7d7c851bb416a2e77f24fc9719dc4c

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
