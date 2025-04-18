import os
import sys
import warnings
import versioneer

uses_pip = "pip" in __file__

if uses_pip:
    # If installed with pip we need to check its version
    try:
        import pip
    except ModuleNotFoundError:
        raise Exception(
            "It looks like you are trying to use pip for installation of the package, but pip is not "
            "installed on your system (or cannot be found). This can lead to problems with missing "
            "dependencies. Please make sure that pip is discoverable. Try python3 -c 'import pip'. "
            "Alternatively, you can also run python3 setup.py install --user.")
    try:
        from packaging import version
    except ModuleNotFoundError:
        warnings.warn(
            "It looks like you are trying to use pip for installation of the package. Please install, "
            "the module packaging by running 'pip3 install --user packaging', since it is needed to perform "
            "additional security checks. You can continue installation. However, if you face problems when "
            "installing or running pyprecice, it might be a good idea to install packaging to enable "
            "additional checks.")
    if "pip" in sys.modules and "packaging" in sys.modules:
        if version.parse(pip.__version__) < version.parse("19.0"):
            # version 19.0 is required, since we are using pyproject.toml for definition of build-time depdendencies.
            # See https://pip.pypa.io/en/stable/news/#id209
            raise Exception(
                "You are using pip version {}. However, pip version >= 19.0 is required. Please upgrade "
                "your pip installation via 'pip3 install --upgrade pip'. You might have to add the --user"
                " flag.".format(pip.__version__))

from setuptools import setup
from setuptools.command.test import test
from setuptools.command.install import install
from Cython.Distutils.extension import Extension
from Cython.Distutils.build_ext import new_build_ext as build_ext
from Cython.Build import cythonize
import numpy
import pkgconfig


# name of Interfacing API
APPNAME = "pyprecice"

PYTHON_BINDINGS_PATH = os.path.dirname(os.path.abspath(__file__))


def get_extensions(is_test):
    compile_args = []
    link_args = []
    compile_args.append("-std=c++17")
    include_dirs = [numpy.get_include()]

    bindings_sources = [os.path.join(PYTHON_BINDINGS_PATH, "cyprecice",
                                     "cyprecice" + ".pyx")]

    if not pkgconfig.exists('libprecice'):
        raise Exception("\n".join([
            "pkg-config was unable to find libprecice.",
            "Please make sure that preCICE was installed correctly and pkg-config is able to find it.",
            "You may need to set PKG_CONFIG_PATH to include the location of the libprecice.pc file.",
            "Use \"pkg-config --modversion libprecice\" for debugging."]))

    print("Found preCICE version " + pkgconfig.modversion('libprecice'))

    compile_args += pkgconfig.cflags('libprecice').split()

    if not is_test:
        link_args += pkgconfig.libs('libprecice').split()
    if is_test:
        bindings_sources.append(os.path.join(PYTHON_BINDINGS_PATH, "test",
                                             "Participant.cpp"))

    return [
        Extension(
            "cyprecice",
            sources=bindings_sources,
            libraries=[],
            language="c++",
            include_dirs=include_dirs,
            extra_compile_args=compile_args,
            extra_link_args=link_args,
            define_macros=[("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION")]
        )
    ]


class my_build_ext(build_ext, object):
    def finalize_options(self):
        try:
            self.distribution.is_test
        except AttributeError:
            self.distribution.is_test = False

        if not self.distribution.ext_modules:
            self.distribution.ext_modules = cythonize(
                get_extensions(self.distribution.is_test),
                compiler_directives={'language_level': "3"})

        super().finalize_options()


class my_install(install, object):
    def finalize_options(self):
        try:
            self.distribution.is_test
        except AttributeError:
            self.distribution.is_test = False

        if not self.distribution.ext_modules:
            self.distribution.ext_modules = cythonize(
                get_extensions(self.distribution.is_test),
                compiler_directives={'language_level': "3"})

        super().finalize_options()


class my_test(test, object):
    def initialize_options(self):
        self.distribution.is_test = True
        super().initialize_options()


this_directory = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

my_cmdclass = {
    'test': my_test,
    'build_ext': my_build_ext,
    'install': my_install}

# build precice.so python extension to be added to "PYTHONPATH" later
setup(
    name=APPNAME,
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(my_cmdclass),
    description='Python language bindings for the preCICE coupling library',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/precice/python-bindings',
    author='the preCICE developers',
    author_email='info@precice.org',
    license='LGPL-3.0',
    python_requires='>=3',
    install_requires=['numpy', 'mpi4py', 'Cython'],
    # mpi4py is only needed, if preCICE was compiled with MPI
    # see https://github.com/precice/python-bindings/issues/8
    packages=['precice'],
    zip_safe=False  # needed because setuptools are used
)
