# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import datetime

project = "pyprecice"
author = "The preCICE developers"
copyright = f"{datetime.datetime.now().year}, {author}"

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "myst_parser",
]

intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "numpy": ("https://numpy.org/doc/stable/", None),
    "mpi4py": ("https://mpi4py.readthedocs.io/en/latest/", None),
}

# exclude_patterns = ["_build", "Thumbs.db", ".DS_Store", ".docs_venv"]
include_patterns = ["*.rst", "*.md"]

html_theme = "sphinx_rtd_theme"

source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}

autodoc_class_signature = "separated"
autodoc_typehints = "description"
autodoc_typehints_format = "short"
autodoc_member_order = "bysource"

suppress_warnings = ["myst.xref_missing"]

# The cython detection relyies on a built and installed version of the package
try:
    import precice
except:
    raise RuntimeError("Cannot import precice. Please install pyprecice first")
