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
    tree \
    apt-utils software-properties-common \
    ssh \
    libasound2 \
    libgstreamer1.0-dev \
    libsamplerate-dev \
    libunwind-dev \
    gcc \
    g++ \
    libc++1 \
    gdb \
    gpg-agent \
    ca-certificates \
    python3 python3-venv python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN pip3 install debugpy pytest cython pylint

# install golang
RUN wget --no-check-certificate --progress=dot:mega https://go.dev/dl/go1.22.3.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xvf go1.22.3.linux-amd64.tar.gz && \
    rm go1.22.3.linux-amd64.tar.gz

# install task
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# install tman 
RUN wget --no-check-certificate --progress=dot:mega https://github.com/TEN-framework/ten_framework/releases/download/0.6.1/tman-linux-clang-release-x64.zip && \
    unzip tman-linux-clang-release-x64.zip && \
    mv ten_manager/bin/tman /usr/local/bin/ && \
    rm -rf tman-*.zip ten_manager

# install ten_gn
RUN git clone https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn && \
    cd /usr/local/ten_gn && \
    git checkout 80a101b316877c9d63bc7fe7e24e3e447a54f06f

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
