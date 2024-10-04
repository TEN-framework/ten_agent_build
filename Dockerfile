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
RUN export ARCH=$(dpkg --print-architecture) && curl -OL https://go.dev/dl/go1.22.3.linux-${ARCH}.tar.gz && \
  rm -rf /usr/local/go && tar -C /usr/local -xvf go1.22.3.linux-${ARCH}.tar.gz && rm go1.22.3.linux-${ARCH}.tar.gz

# install tman 
# RUN export ARCH=$(dpkg --print-architecture) && \
#     if [ ${ARCH} = "amd64" ]; then export ARCH="x64" ; fi && \
#     wget --no-check-certificate --progress=dot:mega https://github.com/TEN-framework/ten_framework/releases/download/0.3.0-alpha/tman-linux-${ARCH}-clang-release.zip && \
#     unzip tman-linux-${ARCH}-clang-release.zip && \
#     mv ten_manager/bin/tman /usr/local/bin/ && \
#     rm -rf tman-*.zip ten_manager

# install ten_gn
RUN git clone https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn && \
    cd /usr/local/ten_gn && \
    git checkout 9bbd871c3a645b63a00e21fcb2bedb69848e703e

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
