from ._version import get_versions
__version__ = "unknown"

import warnings
from cyprecice import Participant, get_version_information


__version__ = get_versions()['version']
del get_versions
