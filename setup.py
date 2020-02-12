import os
import subprocess
from enum import Enum

from setuptools import setup
from setuptools.command.test import test
from Cython.Distutils.extension import Extension
from Cython.Distutils.build_ext import new_build_ext as build_ext
from Cython.Build import cythonize
from distutils.command.install import install
from distutils.command.build import build
from packaging import version
import pip
import numpy

assert(version.parse(pip.__version__) >= version.parse("10.0.1"))  # minimum version 10.0.1 is required. See https://github.com/precice/precice/wiki/Non%E2%80%93standard-APIs#python-bindings-version-of-pip3-is-too-old

# name of Interfacing API
APPNAME = "pyprecice"
# this version should be in sync with the latest supported preCICE version
precice_version = version.Version("2.0.0")  # todo: should be replaced with precice.get_version(), if possible or we should add an assertion that makes sure that the version of preCICE is actually supported
# this version number may be increased, if changes for the bindings are required
bindings_version = version.Version("2rc1")
APPVERSION = version.Version(str(precice_version) + "." + str(bindings_version))

PYTHON_BINDINGS_PATH = os.path.dirname(os.path.abspath(__file__))

def get_extensions(is_test):
    compile_args = []
    link_args = []    
    compile_args.append("-std=c++11")
    compile_args.append("-I{}".format(numpy.get_include()))

    bindings_sources = [os.path.join(PYTHON_BINDINGS_PATH, "precice") + ".pyx"]
    test_sources = [os.path.join(PYTHON_BINDINGS_PATH, "test", "test_bindings_module" + ".pyx")]
    if not is_test:
        link_args.append("-lprecice")
    if is_test:
        bindings_sources.append(os.path.join(PYTHON_BINDINGS_PATH, "test", "SolverInterface.cpp"))
        test_sources.append(os.path.join(PYTHON_BINDINGS_PATH, "test", "SolverInterface.cpp"))

    return [
        Extension(
                "precice",
                sources=bindings_sources,
                libraries=[],
                language="c++",
                extra_compile_args=compile_args,
                extra_link_args=link_args
            ),
        Extension(
                "test_bindings_module",
                sources=test_sources,
                libraries=[],
                language="c++",
                extra_compile_args=compile_args,
                extra_link_args=link_args
            )
    ]

class my_build_ext(build_ext, object):
    def initialize_options(self):
        try:
            self.distribution.is_test
        except AttributeError:
            self.distribution.is_test = False
        
        super().initialize_options()
        
    def finalize_options(self):
        if not self.distribution.ext_modules:
            self.distribution.ext_modules = cythonize(get_extensions(self.distribution.is_test))

        super().finalize_options()


class my_install(install, object):
    def initialize_options(self):
        try:
            self.distribution.is_test
        except AttributeError:
            self.distribution.is_test = False

        super().initialize_options()


class my_build(build, object):
    def initialize_options(self):
        try:
            self.distribution.is_test
        except AttributeError:
            self.distribution.is_test = False

        super().initialize_options()

    def finalize_options(self):
        if not self.distribution.ext_modules:
            self.distribution.ext_modules = cythonize(get_extensions(self.distribution.is_test))

        super().finalize_options()

class my_test(test, object):
    def initialize_options(self):
        self.distribution.is_test = True       
        super().initialize_options()

        
this_directory = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()
    
    
# build precice.so python extension to be added to "PYTHONPATH" later
setup(
    name=APPNAME,
    version=str(APPVERSION),
    description='Python language bindings for the preCICE coupling library',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/precice/python-bindings',
    author='the preCICE developers',
    author_email='info@precice.org',
    license='LGPL-3.0',
    python_requires='>=3',
    install_requires=['numpy', 'mpi4py'],  # mpi4py is only needed, if preCICE was compiled with MPI, see https://github.com/precice/python-bindings/issues/8
    cmdclass={'test': my_test,
              'build_ext': my_build_ext,
              'build': my_build,
              'install': my_install},
    package_data={ 'precice': ['*.pxd']},
    include_package_data=True,
    zip_safe=False  #needed because setuptools are used
)
