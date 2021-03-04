# Build stage with Spack pre-installed and ready to be used
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
# this is necessary to avoid timeouts during installation due to interactive installs

# Installing necessary dependencies for preCICE, boost 1.71 from apt-get
RUN apt-get -qq update && apt-get -qq install \
    curl \
    build-essential \
    locales \
    libboost-all-dev \
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

RUN git clone https://github.com/spack/spack.git

WORKDIR /sources
ADD . /sources

# Mount the current sources into the build container
# and build the default environment
RUN /spack/bin/spack --color=always external find --not-buildable
RUN /spack/bin/spack --color=always env create --without-view ci
RUN /spack/bin/spack --color=always -e add py-pyprecice@develop%gcc@9.3.0
RUN /spack/bin/spack --color=always -e ci repo add /sources/spack/repo
RUN /spack/bin/spack --color=always -e ci install --fail-fast --only=dependencies
RUN /spack/bin/spack --color=always clean -a
