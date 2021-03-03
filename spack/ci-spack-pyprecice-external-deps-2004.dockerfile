# Build stage with Spack pre-installed and ready to be used
FROM ubuntu:20.04

# Installing necessary dependencies for preCICE, boost 1.71 from apt-get
RUN apt-get -qq update && apt-get -qq install \
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
RUN source spack/share/spack/setup-env.sh

WORKDIR /sources

# Mount the current sources into the build container
# and build the default environment
ADD . /sources
RUN spack --color=always external find --scope user --not-buildable
RUN spack --color=always env create --without-view ci /sources/spack/spack.yaml
RUN spack --color=always -e ci repo add /sources/spack/repo
RUN spack --color=always -e ci install --fail-fast --only=dependencies
RUN spack --color=always clean -a
