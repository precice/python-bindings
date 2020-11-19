__version__ = "unknown"

from cyprecice import Interface, action_read_iteration_checkpoint, action_write_iteration_checkpoint, action_write_initial_data, get_version_information

from ._version import get_versions
__version__ = get_versions()['version']
del get_versions
