# Python language bindings for the C++ library preCICE

⚠️ The latest version of the documentation for the python bindings can be found on [precice.org](https://precice.org/installation-bindings-python.html). The information from this `README` is currently under revision and will be moved ⚠️

[![Upload Python Package](https://github.com/precice/python-bindings/workflows/Upload%20Python%20Package/badge.svg?branch=master)](https://pypi.org/project/pyprecice/)

This package provides python language bindings for the C++ library [preCICE](https://github.com/precice/precice). Note that the first three digits of the version number of the bindings indicate the preCICE version that the bindings support. The last digit represents the version of the bindings. Example: `v2.0.0.1` and `v2.0.0.2` of the bindings represent versions `1` and `2` of the bindings that are compatible with preCICE `v2.0.0`.

## User documentation

Please refer to [the preCICE documentation](https://www.precice.org/installation-bindings-python.html) for information on how to install and use the python bindings. Information below is intended for advanced users and developers.

## Required dependencies

**preCICE**: Refer to [the preCICE documentation](https://precice.org/installation-overview.html) for information on building and installation.

**C++**: A working C++ compiler, e.g., `g++`.

**MPI**: `mpi4py` requires MPI to be installed on your system.

## Installing the package

We recommend using pip3 (version 19.0.0 or newer required) for the sake of simplicity. You can check your pip3 version via `pip3 --version`. To update pip3, use the following line:

```bash
$ pip3 install --user --upgrade pip
```

### Using pip3

#### preCICE system installs

For system installs of preCICE, installation works out of the box. There are different ways how pip can be used to install pyprecice. pip will fetch cython and other build-time dependencies, compile the bindings and finally install the package pyprecice.

* (recommended) install [pyprecice from PyPI](https://pypi.org/project/pyprecice/)

  ```bash
  $ pip3 install --user pyprecice
  ```

* provide the link to this repository to pip (replace `<branch>` with the branch you want to use, preferably `master` or `develop`)

  ```bash
  $ pip3 install --user https://github.com/precice/python-bindings/archive/<branch>.zip
  ```

* if you already cloned this repository, execute the following command from this directory:

  ```bash
  $ pip3 install --user .
  ```

  *note the dot at the end of the line*

#### preCICE at custom location (setting PATHS)

If preCICE (the C++ library) was installed in a custom prefix, or only built but not installed at all, you have to extend the following environment variables:

* `LIBRARY_PATH`, `LD_LIBRARY_PATH` to the library location, or `$prefix/lib`
* `CPATH` either to the `src` directory or the `$prefix/include`

The preCICE documentation provides more informaiton on [linking preCICE](https://precice.org/installation-linking.html).

### Using Spack

You can also install the python language bindings for preCICE via Spack by installing the Spack package `py-pyprecice`. Refer to [our installation guide for preCICE via Spack](https://precice.org/installation-spack.html) for getting started with Spack.

### Using setup.py

#### preCICE system installs

In this directory, execute:

```bash
$ python3 setup.py install --user
```

#### preCICE at custom location (setting PATHS)

see above. Then run

```bash
$ python3 setup.py install --user
```

#### preCICE at custom location (explicit include path, library path)

1. Install cython and other dependencies via pip3

   ```bash
   $ pip3 install --user setuptools wheel cython packaging numpy
   ```

2. Open terminal in this folder.
3. Build the bindings

   ```bash
   $ python3 setup.py build_ext --include-dirs=$PRECICE_ROOT/src --library-dirs=$PRECICE_ROOT/build/last
   ```

   **Options:**
   * `--include-dirs=`, default: `''`
     Path to the headers of preCICE, point to the sources `$PRECICE_ROOT/src`, or the your custom install prefix `$prefix/include`.

   **NOTES:**

   * If you have built preCICE using CMake, you can pass the path to the CMake binary directory using `--library-dirs`.
   * It is recommended to use preCICE as a shared library here.

4. Install the bindings

   ```bash
   $ python3 setup.py install --user
   ```

5. Clean-up *optional*

   ```bash
   $ python3 setup.py clean --all
   ```

## Test the installation

Update `LD_LIBRARY_PATH` such that python can find `precice.so`

```bash
$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRECICE_ROOT/build/last
```

Run the following to test the installation:

```bash
$ python3 -c "import precice"
```

### Unit tests

1. Clean-up **mandatory** (because we must not link against the real `precice.so`, but we use a mocked version)

   ```bash
   $ python3 setup.py clean --all
   ```

2. Set `CPLUS_INCLUDE_PATH` (we cannot use `build_ext` and the `--include-dirs` option here)

   ```bash
   $ export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$PRECICE_ROOT/src
   ```

3. Run tests with

   ```bash
   $ python3 setup.py test
   ```

## Usage

You can find the documentation of the implemented interface in the file `precice.pyx`. For an example of how `pyprecice` can be used please refer to the [1D elastic tube example](https://precice.org/tutorials-elastic-tube-1d.html#python).

**Note** The python package that is installed is called `pyprecice`. It provides the python module `precice` that can be use in your code via `import precice`, for example.

## Troubleshooting & miscellaneous

### preCICE is not found

The following error shows up during installation, if preCICE is not found:

```bash
  /tmp/pip-install-d_fjyo1h/pyprecice/precice.cpp:643:10: fatal error: precice/Participant.hpp: No such file or directory
    643 | #include "precice/Participant.hpp"
        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  compilation terminated.
  error: command 'x86_64-linux-gnu-gcc' failed with exit status 1
  ----------------------------------------
  ERROR: Failed building wheel for pyprecice
Failed to build pyprecice
ERROR: Could not build wheels for pyprecice which use PEP 517 and cannot be installed directly
```

Or, for preCICE v2:

```bash
  /tmp/pip-install-d_fjyo1h/pyprecice/precice.cpp:643:10: fatal error: precice/SolverInterface.hpp: No such file or directory
    643 | #include "precice/SolverInterface.hpp"
        |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  compilation terminated.
  error: command 'x86_64-linux-gnu-gcc' failed with exit status 1
  ----------------------------------------
  ERROR: Failed building wheel for pyprecice
Failed to build pyprecice
ERROR: Could not build wheels for pyprecice which use PEP 517 and cannot be installed directly
```

There are two possible reasons, why preCICE is not found:

1. preCICE is not installed. Please download and install the C++ library preCICE. See [above](https://github.com/precice/python-bindings/blob/develop/README.md#required-dependencies).
2. preCICE is installed, but cannot be found. Please make sure that preCICE can be found during the installation process. See our wiki page on [linking to preCICE](https://precice.org/installation-linking.html) and [the instructions above](https://github.com/precice/python-bindings/blob/develop/README.md#precice-at-custom-location-setting-paths).

### Version of Cython is too old

In case the compilation fails with `shared_ptr.pxd not found` messages, check if you use the latest version of Cython.

### `Python.h` missing

```bash
$ python3 -m pip install pyprecice
Collecting pyprecice
...
  /tmp/pip-build-7rj4_h93/pyprecice/precice.cpp:25:20: fatal error: Python.h: No such file or directory
  compilation terminated.
  error: command 'x86_64-linux-gnu-gcc' failed with exit status 1

  ----------------------------------------
  Failed building wheel for pyprecice
```

Please try to install `python3-dev`. E.g. via `apt install python3-dev`. Please make sure that you use the correct version (e.g. `python3.5-dev` or `python3.6-dev`). You can check your version via `python3 --version`.

### `libprecice.so` is not found at runtime

```bash
$ python3 -c "import precice"
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: libprecice.so.2: cannot open shared object file: No such file or directory
```

Make sure that your `LD_LIBRARY_PATH` includes the directory that contains `libprecice.so`. The actual path depends on how you installed preCICE. Example: If preCICE was installed using `sudo make install` and you did not define a `CMAKE_INSTALL_PREFIX` the library path is `/usr/local/lib`. This means you have to `export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH`.

### I'm using preCICE < 2.0.0, but there is no matching version of the bindings. What can I do?

If you want to use the old experimental python bindings (released with preCICE version < 2.0.0), please refer to the corresponding preCICE version. Example: for preCICE v1.6.1 there are three different versions of the python bindings: [`precice_future`](https://github.com/precice/precice/tree/v1.6.1/src/precice/bindings/python_future), [`precice`](https://github.com/precice/precice/tree/v1.6.1/src/precice/bindings/python) and [`PySolverInterface`](https://github.com/precice/precice/tree/v1.6.1/src/precice/bindings/PySolverInterface). Installation instructions can be found in the corresponding `README` files.

### Installing the python bindings for Python 2.7.17

*Note that the instructions in this section are outdated and refer to the deprecated python bindings. Until we have updated information on the installation procedure for the python bindings under this use-case, we will keep these instructions, since they might still be very useful* (Originally contributed by [huangq1234553](https://github.com/huangq1234553) to the precice wiki in [`precice/precice/wiki:8bb74b7`](https://github.com/precice/precice/wiki/Dependencies/8bb74b78a7ebc54983f4822af82fb3d638021faa).)

<details><summary>show details</summary>

This guide provides steps to install python bindings for precice-1.6.1 for a conda environment Python 2.7.17 on the CoolMUC. Note that preCICE no longer supports Python 2 after v1.4.0. Hence, some modifications to the python setup code was necessary. Most steps are similar if not identical to the basic guide without petsc or python above. This guide assumes that the Eigen dependencies have already been installed.

Load the prerequisite libraries:

```bash
module load gcc/7
module unload mpi.intel
module load mpi.intel/2018_gcc
module load cmake/3.12.1
```

At the time of this writing `module load boost/1.68.0` is no longer available. Instead
boost 1.65.1 was installed per the `boost and yaml-cpp` guide above.

In order to have the right python dependencies, a packaged conda environment was transferred to
SuperMUC. The following dependencies were installed:

* numpy
* mpi4py

With the python environment active, we have to feed the right python file directories to the cmake command.
Note that -DPYTHON_LIBRARY expects a python shared library. You can likely modify the version to fit what is required.

```bash
mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON -DPRECICE_FEATURE_PETSC_MAPPING=OFF -DPRECICE_FEATURE_PYTHON_ACTIONS=ON -DCMAKE_INSTALL_PREFIX=/path/to/precice -DCMAKE_BUILD_TYPE=Debug .. -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  -DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR')+'/libpython2.7.so')") -DNumPy_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")
make -j 12
make install
```

After installing, make sure you add the preCICE installation paths to your `.bashrc`, so that other programs can find it:

```bash
export PRECICE_ROOT="path/to/precice_install"
export PKG_CONFIG_PATH="path/to/precice_install/lib/pkgconfig:${PKG_CONFIG_PATH}"
export CPLUS_INCLUDE_PATH="path/to/precice_install/include:${CPLUS_INCLUDE_PATH}"
export LD_LIBRARY_PATH="path/to/precice_install/lib:${LD_LIBRARY_PATH}"
```

Then, navigate to the python_future bindings script.

```bash
cd /path/to/precice/src/precice/bindings/python_future
```

Append the following to the head of the file to allow Python2 to run Python3 code. Note that
importing `unicode_literals` from `future` will cause errors in `setuptools` methods as string literals
in code are interpreted as `unicode` with this import.

```python
from __future__ import (absolute_import, division,
                        print_function)
from builtins import (
         bytes, dict, int, list, object, range, str,
         ascii, chr, hex, input, next, oct, open,
         pow, round, super,
         filter, map, zip)
```

Modify `mpicompiler_default = "mpic++"` to `mpicompiler_default = "mpicxx"` in line 100.
Run the setup file using the default Python 2.7.17.

```bash
python setup.py install --user
```

</details>

### ValueError while importing preCICE

If you face the error:

```bash
ValueError: numpy.ndarray size changed, may indicate binary incompatibility. Expected 88 from C header, got 80 from PyObject
```

make sure that you are using an up-to-date version of NumPy. You can update NumPy with

```bash
pip3 install numpy --upgrade
```

## Contributors

* [Benjamin Rodenberg](https://github.com/BenjaminRodenberg)
* [Ishaan Desai](https://github.com/IshaanDesai)
* [Saumitra Vinay Joshi](https://github.com/saumiJ) contributed first working prototype in [`3db9c9` on `precice/precice`](https://github.com/precice/precice/commit/3db9c95e527db1e1cacb2fd116a5ce13ee877513)
* [Frédéric Simonis](https://github.com/fsimonis)
* [Florian Lindner](https://github.com/floli)
* [Benjamin Uekermann](https://github.com/uekerman)
* [Gerasimos Chourdakis](https://github.com/MakisH)
