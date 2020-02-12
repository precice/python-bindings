Python language bindings for the C++ library preCICE
----------------------------------------------------

<a style="text-decoration: none" href="https://travis-ci.org/precice/python-bindings" target="_blank">
    <img src="https://travis-ci.org/precice/python-bindings.svg?branch=develop" alt="Build status">
</a>

This package provides python language bindings for the C++ library [preCICE](https://github.com/precice/precice). Note that the first three digits of the version number of the bindings indicate the preCICE version that the bindings support. The last digit represents the version of the bindings. Example: `v2.0.0.1` of the bindings represents version `1` of the bindings which is compatible with preCICE `v2.0.0`.

# Required dependencies

* **preCICE**: Refer to (the preCICE wiki)[https://github.com/precice/precice/wiki#1-get-precice] for information on installation.

# Installing the package

We recommend [using pip3](https://github.com/precice/precice/blob/develop/src/precice/bindings/python/README.md#using-pip3) for the sake of simplicity.

## Using pip3

### preCICE system installs

For system installs of preCICE, this works out of the box.

You can either install from PyPI

```
$ pip3 install --user pyprecice
```

provide the link to this repository to pip (replace `<branch>` with the branch you want to use, preferably `master` or `develop`)

```
$ pip3 install --user https://github.com/precice/python-bindings/archive/<branch>.zip
```

or, if you cloned this repository, execute the following command from this directory:

```
$ pip3 install --user .
```
*note the dot at the end of the line*

This will fetch cython, compile the bindings and finally install the package pyprecice.

### preCICE at custom location (setting PATHS)

If preCICE (the C++ library) was installed in a custom prefix, or not installed at all, you have to extend the following environment variables:

- `LIBRARY_PATH`, `LD_LIBRARY_PATH` to the library location, or `$prefix/lib`
- `CPATH` either to the `src` directory or the `$prefix/include`

## Using setup.py

### preCICE system installs

In this directory, execute:
```
$ python3 setup.py install --user
```

### preCICE at custom location (setting PATHS)

see above. Then run
```
$ python3 setup.py install --user
```

### preCICE at custom location (explicit include path, library path)

1. Install cython via pip3
```
$ pip3 install --user cython
```
2. Open terminal in this folder.
3. Build the bindings

```
$ python3 setup.py build_ext --include-dirs=$PRECICE_ROOT/src --library-dirs=$PRECICE_ROOT/build/last
```

**Options:**
- `--include-dirs=`, default: `''` 
  Path to the headers of preCICE, point to the sources `$PRECICE_ROOT/src`, or the your custom install prefix `$prefix/include`.
  
**NOTES:**

- If you build preCICE using CMake, you can pass the path to the CMake binary directory using `--library-dirs`.
- It is recommended to use preCICE as a shared library here.

4. Install the bindings
```
$ python3 setup.py install --user
```

5. Clean-up _optional_
```
$ python3 setup.py clean --all
```

# Test the installation

Update `LD_LIBRARY_PATH` such that python can find `precice.so`
```
$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRECICE_ROOT/build/last
```

Run the following to test the installation:
```
$ python3 -c "import precice"
```

## Unit tests

1. Clean-up __mandatory__ (because we must not link against the real `precice.so`, but we use a mocked version)
```
$ python3 setup.py clean --all
```

2. Set `CPLUS_INCLUDE_PATH` (we cannot use `build_ext` and the `--include-dirs` option here)
```
$ export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$PRECICE_ROOT/src
```

3. Run tests with
```
$ python3 setup.py test
```

**NOTE:**
- For an example of how `pyprecice` can be used, refer to the [1D elastic tube example](https://github.com/precice/precice/wiki/1D-elastic-tube-using-the-Python-API).

# Troubleshooting & miscellaneous

### preCICE is not found

The following error shows up during installation, if preCICE is not found:

```
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
2. preCICE is installed, but cannot be found. Please make sure that preCICE can be found during the installation process. See our wiki page on [linking to preCICE](https://github.com/precice/precice/wiki/Linking-to-preCICE) and [the instructions above](https://github.com/precice/python-bindings/blob/develop/README.md#precice-at-custom-location-setting-paths).

### Version of Cython is too old

In case the compilation fails with `shared_ptr.pxd not found` messages, check if you use the latest version of Cython.

### Version of pip3 is too old

If you see the following error
```
error: option --single-version-externally-managed not recognized
```
your version of pip might be too old. Please update pip and try again. One possible way for updating pip is to run the following commands:
```
wget -q https://bootstrap.pypa.io/get-pip.py -O get-pip.py && python3 get-pip.py
```
*Be aware that `python3 get-pip.py` might require root privileges.*

Check your version of pip via `pip3 --version`. For version 8.1.1 and 9.0.1 we know that this problem occurs. *Remark:* you get versions 8.1.1 of pip if you use `sudo apt install python3-pip` on Ubuntu 16.04 (pip version 9.0.1 on Ubuntu 18.04)

### I'm using preCICE < 2.0.0, but there is no matching version of the bindings. What can I do?

If you want to use the old experimental python bindings (released with preCICE version < 2.0.0), please refer to the documentation of the corresponding preCICE version. 

### Installing the python bindings for Python 2.7.17

*Note that the instructions in this section are outdated and refer to the deprecated python bindings. Until we have updated information on the installation procedure for the python bindings under this use-case, we will keep these instructions, since they might still be very useful* (Originally contributed by [huangq1234553](https://github.com/huangq1234553) to the precice wiki in [`precice/precice/wiki:8bb74b7`](https://github.com/precice/precice/wiki/Dependencies/8bb74b78a7ebc54983f4822af82fb3d638021faa).)

<details><summary>show details</summary>

This guide provides steps to install python bindings for precice-1.6.1 for a conda environment Python 2.7.17 on the CoolMUC. Note that preCICE no longer supports Python 2 after v1.4.0. Hence, some modifications to the python setup code was necessary. Most steps are similar if not identical to the basic guide without petsc or python above. This guide assumes that the Eigen dependencies have already been installed.

Load the prerequisite libraries:
```
module load gcc/7
module unload mpi.intel
module load mpi.intel/2018_gcc
module load cmake/3.12.1
```
At the time of this writing `module load boost/1.68.0` is no longer available. Instead
boost 1.65.1 was installed per the `boost and yaml-cpp` guide above. 

In order to have the right python dependencies, a packaged conda environment was transferred to
SuperMUC. The following dependencies were installed:
- numpy
- mpi4py

With the python environment active, we have to feed the right python file directories to the cmake command.
Note that -DPYTHON_LIBRARY expects a python shared library. You can likely modify the version to fit what is required.
```
mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON -DPRECICE_PETScMapping=OFF -DPRECICE_PythonActions=ON -DCMAKE_INSTALL_PREFIX=/path/to/precice -DCMAKE_BUILD_TYPE=Debug .. -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  -DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR')+'/libpython2.7.so')") -DNumPy_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")
make -j 12
make install
```
After installing, make sure you add the preCICE installation paths to your `.bashrc`, so that other programs can find it:
```
export PRECICE_ROOT="path/to/precice_install"
export PKG_CONFIG_PATH="path/to/precice_install/lib/pkgconfig:${PKG_CONFIG_PATH}"
export CPLUS_INCLUDE_PATH="path/to/precice_install/include:${CPLUS_INCLUDE_PATH}"
export LD_LIBRARY_PATH="path/to/precice_install/lib:${LD_LIBRARY_PATH}"
```
Then, navigate to the python_future bindings script.
```
cd /path/to/precice/src/precice/bindings/python_future
```
Append the following to the head of the file to allow Python2 to run Python3 code. Note that
importing `unicode_literals` from `future` will cause errors in `setuptools` methods as string literals 
in code are interpreted as `unicode` with this import.
```
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
```
python setup.py install --user
```
</details>

# Contributors

* [Benjamin Rüth](https://github.com/BenjaminRueth)
* [Ishaan Desai](https://github.com/IshaanDesai)
* [Saumitra Vinay Joshi](https://github.com/saumiJ) contributed first working prototype in [`3db9c9` on `precice/precice`](https://github.com/precice/precice/commit/3db9c95e527db1e1cacb2fd116a5ce13ee877513)
* [Frédéric Simonis](https://github.com/fsimonis)
* [Florian Lindner](https://github.com/floli)
* [Benjamin Uekermann](https://github.com/uekerman)
* [Gerasimos Chourdakis](https://github.com/MakisH)
