__version__ = "unknown"

import warnings
from cyprecice import Interface, action_read_iteration_checkpoint, action_write_iteration_checkpoint, action_write_initial_data, get_version_information


def SolverInterface(*args):
    """
    This is just a dummy function to avoid wrong usage of the interface. Please use precice.Interface, if you want to establish a connection to preCICE. See https://github.com/precice/python-bindings/issues/92 for more information.
    """
    warnings.warn("please use precice.Interface to create the interface to C++ preCICE. Note that this function (precice.SolverInterface) does not do anything but throwing this warning. See https://github.com/precice/python-bindings/issues/92 for more information.")


from ._version import get_versions
__version__ = get_versions()['version']
del get_versions
