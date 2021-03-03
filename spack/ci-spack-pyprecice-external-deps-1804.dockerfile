# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-bionic:latest 
WORKDIR /sources

# Installing necessary dependacies for preCICE, boost 1.65 from apt-get
RUN apt-get -qq update && apt-get -qq install \
    build-essential \
    locales \
    libopenmpi-dev \
    libopenblas-dev \
    zlib \
    libncurses-dev \
    libeigen3-dev \
    libxml2-dev \
    git \
    python3-numpy \
    python3-dev \
    petsc-dev \
    wget \
    bzip2 \
    cmake && \
    rm -rf /var/lib/apt/lists/*

# Mount the current sources into the build container
# and build the default environment
ADD . /sources
RUN spack --color=always env create --without-view ci /sources/spack/spack-external.yaml && \
    spack --color=always -e ci repo add /sources/spack/repo && \
    spack --color=always -e ci external find && \
    spack --color=always -e ci install --fail-fast --only=dependencies && \
    spack --color=always clean -a
