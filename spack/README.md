# Spack package: py-pyprecice

The spack package `py-pyprecice` provides the python bindings via spack and was submitted via https://github.com/spack/spack/pull/19558. This folder contains the spack package script that can be used for testing whether the spack installation works.

Note that the file `var/spack/repos/builtin/packages/py-pyprecice/package.py` is a template that can be specified using `jinja2`. Run `python3 jinja-instrantiate.py` to do so. You may use the `--branch` argument to specify a branch. Example:
```
python3 jinja-instantiate --branch feature > my_package_script.py
```

## Docker image ci-spack-pyprecice-deps-1804

The test `build_spack` in `.github/workflows/build-spack.yml` uses the image `benjaminrueth/ci-spack-pyprecice-deps-1804` to reduce build time. Use the file `ci-spack-pyprecice-deps-1804.dockerfile` from this folder for building this image:
```
docker build -f ci-spack-pyprecice-deps-1804.dockerfile -t USERNAME/ci-spack-pyprecice-deps-1804.dockerfile .
docker push USERNAME/ci-spack-pyprecice-deps-1804.dockerfile
```
