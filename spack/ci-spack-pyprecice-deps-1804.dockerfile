# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-bionic:latest
RUN spack env create precice
RUN spack env activate precice
RUN spack install boost@1.74.0 cmake@3.18.4 eigen@3.3.8 petsc@3.14.1
RUN spack install pkgconfig
RUN spack env activate precice && spack concretize -f && spack install pkgconfig && spack install precice@develop

# Install python dependencies for pyprecice
RUN spack install py-setuptools py-wheel py-cython py-numpy py-mpi4py
