ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
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
    ca-certificates

# install python3.12
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# set python3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 312 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 312 \
    && update-alternatives --install /usr/bin/python-config python-config /usr/bin/python3.12-config 312 \
    && update-alternatives --install /usr/bin/python3-config python3-config /usr/bin/python3.12-config 312 \
    && update-alternatives --set python3 /usr/bin/python3.12 \
    && update-alternatives --set python /usr/bin/python3.12 \
    && update-alternatives --set python-config /usr/bin/python3.12-config \
    && update-alternatives --set python3-config /usr/bin/python3.12-config

# install latest pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    python3.12 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# verify python versions
RUN python --version && \
    python3 --version && \
    pip --version && \
    pip3 --version && \
    python3.12 -c "import venv; print('venv module available')" && \
    python-config --version && \
    python3-config --version && \
    python-config --includes --libs --cflags

# clear cache
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install debugpy pytest pytest-cov pytest-mock cython pylint pylint-exit black

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
RUN wget --no-check-certificate --progress=dot:mega https://github.com/TEN-framework/ten_framework/releases/download/0.9.6/tman-linux-release-x64.zip && \
    unzip tman-linux-release-x64.zip && \
    mv ten_manager/bin/tman /usr/local/bin/ && \
    rm -rf tman-*.zip ten_manager

# install ten_gn
RUN git clone https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn && \
    cd /usr/local/ten_gn && \
    git checkout 0.1.1

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
