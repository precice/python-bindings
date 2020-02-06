Python language bindings for the C++ library preCICE
----------------------------------------------------

<a style="text-decoration: none" href="https://travis-ci.org/precice/python-bindings" target="_blank">
    <img src="https://travis-ci.org/precice/python-bindings.svg?branch=develop" alt="Build status">
</a>

# Installing the package

We recommend [using pip3](https://github.com/precice/precice/blob/develop/src/precice/bindings/python/README.md#using-pip3) for the sake of simplicity.

## Using pip3

### preCICE system installs

For system installs of preCICE, this works out of the box.

In this directory, execute:
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

### preCICE at custom location (explicit include path, library path, or mpicompiler)

1. Install cython via pip3
```
$ pip3 install --user cython
```
2. Open terminal in this folder.
3. Build the bindings

```
$ python3 setup.py build_ext --mpicompiler=mpicc --include-dirs=$PRECICE_ROOT/src --library-dirs=$PRECICE_ROOT/build/last
```

**Options:**
- `--include-dirs=`, default: `''` 
  Path to the headers of preCICE, point to the sources `$PRECICE_ROOT/src`, or the your custom install prefix `$prefix/include`.
- `--mpicompiler=`, default: `mpic++` 
  MPI compiler wrapper of choice.

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
python3 setup.py test
```

# Using with MPI

If preCICE was compiled with MPI, you have to initialize MPI prior to initializing the Interface object.
To do so, install the package `mpi4py` and import `MPI`.

```
$ pip3 install --user mpi4py
```

```python
from mpi4py import MPI # Initialize MPI 
```

**NOTE:**
- For an example of how `pyprecice` can be used, refer to the [1D elastic tube example](https://github.com/precice/precice/wiki/1D-elastic-tube-using-the-Python-API).
- In case the compilation fails with `shared_ptr.pxd not found` messages, check if you use the latest version of Cython.
- If you want to use the old python bindings (released with preCICE version < 2.0.0), please refer to the documentation of the corresponding preCICE version

# Troubleshooting

### python bindings: version of pip3 is too old

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

# Contributors

* [Benjamin Rüth](https://github.com/BenjaminRueth)
* [Ishaan Desai](https://github.com/IshaanDesai)
* [Saumitra Vinay Joshi](https://github.com/saumiJ) contributed first working prototype in [`3db9c9` on `precice/precice`](https://github.com/precice/precice/commit/3db9c95e527db1e1cacb2fd116a5ce13ee877513)
* [Frédéric Simonis](https://github.com/fsimonis)
* [Florian Lindner](https://github.com/floli)
* [Benjamin Uekermann](https://github.com/uekerman)
* [Gerasimos Chourdakis](https://github.com/MakisH)
