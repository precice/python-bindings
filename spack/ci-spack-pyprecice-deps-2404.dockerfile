# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-noble:latest

# Mount the current sources into the build container
# and build the default environment
ADD ./spack/repo /py-pyprecice-repo
RUN spack --color=always env create --without-view ci && \
    spack --color=always -e ci repo add /py-pyprecice-repo && \
    spack --color=always -e ci add pyprecice.test.py-pyprecice@develop target=x86_64 && \
    spack --color=always -e ci install --fail-fast --only=dependencies && \
    spack --color=always clean -a
