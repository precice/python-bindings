# Spack package: py-pyprecice

The Spack package `py-pyprecice` provides the python bindings via Spack and was submitted via https://github.com/spack/spack/pull/19558. This folder contains the Spack package script that can be used for testing whether the Spack installation works.

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
## When a new spack release is necessary

* Add checksum of newest version(s) to https://github.com/precice/python-bindings/blob/develop/spack/var/spack/repos/builtin/packages/py-pyprecice/package.py. You can get checksum for any released version by running `spack checksum py-pyprecice`.
* Run `python3 jinja-instantiate > package.py` to generate the latest version of `package.py`.
* Use `package.py` together with the patches provided in `python-bindings/spack/var/spack/repos/builtin/packages/py-pyprecice` to [create a pull request for Spack](https://github.com/spack/spack/compare) and submit the new release.
