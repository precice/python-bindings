# Spack package: py-pyprecice

The Spack package `py-pyprecice` provides the python bindings via Spack and was submitted via [pull request 19558](https://github.com/spack/spack/pull/19558) in the Spack repository. This folder contains the Spack package script that can be used for testing whether the Spack installation works.

## Docker image `precice/ci-spack-pyprecice-deps-1804`

The workflow `build-spack-pyprecice-deps` in `.github/workflows/build-env.yml` creates the image `precice/ci-spack-pyprecice-deps-1804`. This image contains all dependencies of `py-pyprecice@develop`.

The workflow `build_spack` in `.github/workflows/build-spack.yml` uses the image `precice/ci-spack-pyprecice-deps-1804` to reduce build time. The workflow uses the `package.py` from this repository to build the latest version of the bindings and run a small test on this version.

## When a new Spack release is necessary

* Add checksum of newest version(s) to the [package recipe in `package.py`](https://github.com/precice/python-bindings/blob/develop/spack/repo/packages/py-pyprecice/package.py). You can get checksum for any released version by running `spack checksum py-pyprecice`.
* Check whether the new release works locally. You can add the Spack repo in this repository and do the following:

  1. Add the repository to your Spack installation if you have not done that before. You can check the repositories available with your Spack installation via `spack repo list`. If there is a repository called `pyprecice.test`, check whether it points to the correct path. The correct path is the `spack/repo` directory of python-bindings repository. If the repository is missing, add it via

  ```bash
  spack repo add ${REPOSITORY_ROOT}/spack/repo
  ```

  2. Build the new python bindings. Usually, we use a new Spack environment. This is created and loaded via

  ```text
  spack env create pyprecicetest-VERSIONNUMBER
  spack env activate -p pyprecicetest-VERSIONNUMBER
  ```

  Note that the dots `.` in the version number must be replaced by underscores or similar. This means, one would create an environment named `pyprecicetest-2_0_0_1` instead of `pyprecicetest-2.0.0.1` since the `.` character is not allowed for Spack environments.

  3. We add the `py-pyprecice` package from our repository to the environment via

  ```text
  spack add pyprecice.test.py-pyprecice@VERSIONNUMBER
  ```

  This ensures that one uses the local repository which has the namespace `pyprecice.test` when installing `py-precice`. Note that when speciying the `VERSIONNUMBER` you use the actual version number with dots, e.g. `2.0.0.1`.

  4. Concretize the software packages

  ```text
  spack concretize -f
  ```

  and check whether everything looks good. You might want to edit the environment of the Spack environment (the `spack.yaml` file) and enforce combined concretization by adding `concretization: together` at the end of the file. You might want to double check whether the correct repository is used by calling

  ```text
  spack spec -N py-pyprecice@VERSIONNUMBER
  ```

  It will print the concretization and prefixes each packages with the repository it will be installed from.

  5. Run `spack install` to actually install the package.

  6. If the installation went through, check the installation by running `python3 -c "import precice; print(precice.__version__)"`. This should print the version number of the Python bindings you have installed. *Note*: In order to make the bindings available one might have to reload the environment via

  ```text
  despacktivate
  spack env activate -p pyprecicetest-VERSIONNUMBER
  ```

  7. Ideally one runs the solverdummy with the freshly installed Python bindings.

* Use `package.py` together with the patches provided in `python-bindings/spack/repo/packages/py-pyprecice` to [create a pull request for Spack](https://github.com/spack/spack/compare) and submit the new release.
* After the pull request in the Spack repository is merged, merge the current package configuration into the repository of the Python bindings if necessery.