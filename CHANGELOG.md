# Changelog of Python language bindings for preCICE

All notable changes to this project will be documented in this file.

## 3.0.0.0

* Add Cython as build time dependency https://github.com/precice/python-bindings/pull/177
* Update CMake configuration flags for preCICE source installation in Actions. https://github.com/precice/python-bindings/commit/23a840144c2647d6cf09c0ed87be3b768a22feb7
* Remove API functions `has_mesh` and `has_data` and rename `get_mesh_vertices_and_ids` to `get_mesh_vertices_and_coordinates`. https://github.com/precice/python-bindings/commit/cd446d2807b841d81a4cf5c9dd6656ab43c278c3
* Update API according to preCICE v3.0.0 https://github.com/precice/python-bindings/pull/179

## 2.5.0.4

* Add `tag_prefix = v` in versioneer configuration of `setup.cfg`.

## 2.5.0.3

* Update from versioneer 0.19 to 0.29.
* Add `cimport numpy` to avoid a segmentation fault originating from using Cython v3.0.0. https://github.com/precice/python-bindings/issues/182

## 2.5.0.2

* Add Waveform API introduced in preCICE v2.4.0.

## 2.5.0.1

* Add pkgconfig as dependency to the pythonpublish workflow https://github.com/precice/python-bindings/commit/200dc2aba160e18a7d1dae44ef3493d546e69eb9

## 2.5.0.0

* Bindings now use pkgconfig to determine flags and link to preCICE. https://github.com/precice/python-bindings/pull/149

## 2.4.0.0

* Move solverdummy into examples/ folder and remove MeshName from its input arguments. https://github.com/precice/python-bindings/pull/141
* Remove MeshName from input arguments of solverdummy. https://github.com/precice/python-bindings/pull/142

## 2.3.0.1

* Improve CI w.r.t spack package. https://github.com/precice/python-bindings/pull/117
* Mesh connectivity requirement API function: https://github.com/precice/python-bindings/pull/126
* Direct mesh access API functions: https://github.com/precice/python-bindings/pull/124

## 2.2.1.1

* Remove Travis CI https://github.com/precice/python-bindings/pull/103
* Improve CI w.r.t. testing dockerimage and autopep8 formatting: https://github.com/precice/python-bindings/pull/98

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
