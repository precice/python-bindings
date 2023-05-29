"""precice

The python module precice offers python language bindings to the C++ coupling library precice. Please refer to precice.org for further information.
"""

cimport numpy as np
cimport cython
cimport Participant as CppParticipant

from cpython.version cimport PY_MAJOR_VERSION  # important for determining python version in order to properly normalize string input. See http://docs.cython.org/en/latest/src/tutorial/strings.html#general-notes-about-c-strings and https://github.com/precice/precice/issues/68 .

@cython.embedsignature(True)
cdef class Participant:
    cdef CppParticipant.Participant *thisptr # hold a C++ instance being wrapped
