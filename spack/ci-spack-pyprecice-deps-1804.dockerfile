# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-bionic:latest
RUN spack env create precice
# Install dependencies for precice and py-pyprecice
RUN spack env activate precice \ 
    && spack add boost@1.74.0 cmake@3.18.4 eigen@3.3.8 openssh petsc@3.14.1 pkgconfig precice@develop py-setuptools py-wheel py-cython py-numpy py-mpi4py \
    && spack concretize -f \
    && spack install
