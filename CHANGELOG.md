# Changelog of Python language bindings for preCICE

All notable changes to this project will be documented in this file.

## latest

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
