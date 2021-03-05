# Build stage with Spack pre-installed and ready to be used
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
# this is necessary to avoid timeouts during installation due to interactive installs

# Installing necessary dependencies for preCICE, boost 1.71 from apt-get
RUN apt-get -qq update && apt-get -qq install \
    curl \
    unzip \
    build-essential \
    locales \
    libboost-all-dev \
    libeigen3-dev \
    libxml2-dev \
    git \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    python3-numpy \
    petsc-dev \
    mpich \
    wget \
    bzip2 \
    cmake && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/spack/spack.git

ADD ./spack/repo /py-pyprecice-repo

RUN source /spack/share/spack/setup-env.sh && \
    spack --color=always external find --not-buildable && \
    spack --color=always env create --without-view ci && \
    spack --color=always -e ci add py-pyprecice@develop%gcc@9.3.0 && \
    spack --color=always -e ci repo add /py-pyprecice-repo && \
    spack --color=always -e ci install --fail-fast --only=dependencies && \
    spack --color=always clean -a
