from cyprecice import Participant, get_version_information
from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("pyprecice")
except PackageNotFoundError:
    # package is not installed
    pass
