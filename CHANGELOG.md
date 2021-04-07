# Changelog of Python language bindings for preCICE

All notable changes to this project will be documented in this file.

## 2.2.0.2

* Improved error messgaes for all assertions. https://github.com/precice/python-bindings/pull/9
* Improve CI w.r.t spack package. https://github.com/precice/python-bindings/pull/89

## 2.2.0.1

* Format complete codebase according to PEP8 and test formatting. https://github.com/precice/python-bindings/pull/82
* Added checks for correct input to API functions accepting array-like input (e.g. `write_block_scalar_data`). https://github.com/precice/python-bindings/pull/80
* Use github actions for CI. https://github.com/precice/python-bindings/pull/67, https://github.com/precice/python-bindings/pull/68
* Do major restructuring of codebase. https://github.com/precice/python-bindings/pull/71
* Support `__version__` and provide version via python-versioneer. https://github.com/precice/python-bindings/pull/70
* `packaging` and `pip` are now optional dependencies. https://github.com/precice/python-bindings/pull/63
* Feature: Bindings are now available via Spack. https://github.com/spack/spack/pull/19558

## 2.1.1.2

* Bugfix: Bindings also support empty read/write data for block read/write operations (like C++ preCICE API). https://github.com/precice/python-bindings/pull/69

## 2.1.1.1

* Bindings can now handle mesh initialization with no vertices. This behavior is consistent with the C++ preCICE API.
* Adds a CHANGELOG to the project.

## 2.1.0.1

* Update solverdummy to include data transfer.

## 2.0.2.1

* No relevant features or fixes. This version is released for compatibility reasons.

## 2.0.1.1

* No relevant features or fixes. This version is released for compatibility reasons.

## 2.0.0.2

* Improvement of PyPI intergration.

## 2.0.0.1

* Introduces new versioning system. See https://github.com/precice/python-bindings/issues/31.
* First independent release of the python bindings.
* Name the package `pyprecice`.
* Publish package on [PyPI](https://pypi.org/project/pyprecice/).
