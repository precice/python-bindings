import pathlib
from setuptools import setup
from Cython.Distutils.extension import Extension
from Cython.Build import cythonize
import numpy
import pkgconfig
import os

MOCKED_ENV = "PYPRECICE_MOCKED"


def get_extensions():
    if not pkgconfig.exists("libprecice"):
        raise Exception(
            "\n".join(
                [
                    "pkg-config was unable to find libprecice.",
                    "Please make sure that preCICE was installed correctly and pkg-config is able to find it.",
                    "You may need to set PKG_CONFIG_PATH to include the location of the libprecice.pc file.",
                    'Use "pkg-config --modversion libprecice" for debugging.',
                ]
            )
        )

    print("Found preCICE version " + pkgconfig.modversion("libprecice"))

    compile_args = ["-std=c++17"]
    link_args = []
    include_dirs = [numpy.get_include()]
    bindings_sources = ["cyprecice/cyprecice.pyx"]
    compile_args += pkgconfig.cflags("libprecice").split()

    if os.environ.get(MOCKED_ENV) is not None:
        print(f"Building mocked pyprecice as {MOCKED_ENV} is set")
        bindings_sources.append("test/Participant.cpp")
    else:
        link_args += pkgconfig.libs("libprecice").split()

    return [
        Extension(
            "cyprecice",
            sources=bindings_sources,
            libraries=[],
            language="c++",
            include_dirs=include_dirs,
            extra_compile_args=compile_args,
            extra_link_args=link_args,
            define_macros=[("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION")],
        )
    ]


setup(
    ext_modules=cythonize(get_extensions(), compiler_directives={"language_level": "3"})
)
