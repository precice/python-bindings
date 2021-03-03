# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-bionic:latest 
WORKDIR /sources

# Mount the current sources into the build container
# and build the default environment
ADD . /sources
RUN spack --color=always env create --without-view ci /sources/spack/spack-external.yaml && \
RUN spack --color=always -e ci repo add /sources/spack/repo && \
RUN spack --color=always -e ci external find && \
RUN spack --color=always -e ci install --fail-fast --only=dependencies && \
RUN spack --color=always clean -a
