ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

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
    libnuma-dev \
    gcc \
    g++ \
    libc++1 \
    gdb \
    gpg-agent \
    ca-certificates \
    python3 python3-venv python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN pip3 install debugpy pytest pytest-cov pytest-mock cython pylint pylint-exit black

# install vllm
#RUN pip install vllm
RUN git clone https://github.com/vllm-project/vllm.git
RUN pip install cmake>=3.26 wheel packaging ninja "setuptools-scm>=8" numpy
RUN cd vllm && pip install -v -r requirements/cpu.txt --extra-index-url https://download.pytorch.org/whl/cpu
RUN git clone -b rls-v3.5 https://github.com/oneapi-src/oneDNN.git
RUN cmake -B ./oneDNN/build -S ./oneDNN -G Ninja -DONEDNN_LIBRARY_TYPE=STATIC \
    -DONEDNN_BUILD_DOC=OFF \
    -DONEDNN_BUILD_EXAMPLES=OFF \
    -DONEDNN_BUILD_TESTS=OFF \
    -DONEDNN_BUILD_GRAPH=OFF \
    -DONEDNN_ENABLE_WORKLOAD=INFERENCE \
    -DONEDNN_ENABLE_PRIMITIVE=MATMUL
RUN cmake --build ./oneDNN/build --target install --config Release -j 1
RUN cd vllm && VLLM_TARGET_DEVICE=cpu MAX_JOBS=2 python3 setup.py install

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
RUN wget --no-check-certificate --progress=dot:mega https://github.com/TEN-framework/ten_framework/releases/download/0.8.18/tman-linux-clang-release-x64.zip && \
    unzip tman-linux-clang-release-x64.zip && \
    mv ten_manager/bin/tman /usr/local/bin/ && \
    rm -rf tman-*.zip ten_manager

# install ten_gn
RUN git clone https://github.com/TEN-framework/ten_gn.git /usr/local/ten_gn && \
    cd /usr/local/ten_gn && \
    git checkout 0.1.1

ENV PATH=/usr/local/go/bin:/usr/local/ten_gn:$PATH
