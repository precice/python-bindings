# Spack package: py-pyprecice

The Spack package `py-pyprecice` provides the python bindings via Spack and was submitted via https://github.com/spack/spack/pull/19558. This folder contains the Spack package script that can be used for testing whether the Spack installation works.

## Docker image `precice/ci-spack-pyprecice-deps-1804`

The workflow `build-spack-pyprecice-deps` in `.github/workflows/build-env.yml` creates the image `precice/ci-spack-pyprecice-deps-1804`. This image contains all dependencies of `py-pyprecice@develop`.

The workflow `build_spack` in `.github/workflows/build-spack.yml` uses the image `precice/ci-spack-pyprecice-deps-1804` to reduce build time. The workflow uses the `package.py` from this repository to build the latest version of the bindings and run a small test on this version.

## When a new spack release is necessary

* Add checksum of newest version(s) to https://github.com/precice/python-bindings/blob/develop/spack/repo/packages/py-pyprecice/package.py. You can get checksum for any released version by running `spack checksum py-pyprecice`.
* Use `package.py` together with the patches provided in `python-bindings/spack/repo/packages/py-pyprecice` to [create a pull request for Spack](https://github.com/spack/spack/compare) and submit the new release.
