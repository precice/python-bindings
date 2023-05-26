from libcpp        cimport bool
from libcpp.set    cimport set
from libcpp.string cimport string

cdef extern from "<string_view>" namespace "precice":
    cdef cppclass string_view:
        string_view() except +
        string_view(const string&) except +  # necessary to cast Python strings to string_view before handing over to C++ API

cdef extern from "<span>" namespace "precice":
    cdef cppclass span:
        span() except +
        span(<double* size>) except +

cdef extern from "precice/Participant.hpp" namespace "precice":
    cdef cppclass Participant:
        # construction and configuration

        Participant (const string&, const string&, int, int) except +

        Participant (const string&, const string&, int, int, void*) except +

        void configure (const string&)

        # steering methods

        double initialize ()

        double advance (double computedTimestepLength)

        void finalize()

        # status queries

        int getMeshDimensions(const char* meshName) const

        int getDataDimensions(const char* meshName, const char* dataName) const

        bool isCouplingOngoing() const

        bool isTimeWindowComplete() const

        double getMaxTimeStepSize() const

        bool requiresInitialData()

        bool requiresReadingCheckpoint()

        bool requiresWritingCheckpoint()

        # mesh access

        bool hasMesh (const char* meshName) const

        bool requiresMeshConnectivityFor (const char* meshName) const

        int setMeshVertex (const char* meshName, const double* position)

        int getMeshVertexSize (const char* meshName) const

        void setMeshVertices (const char* meshName, const double* positions, int* ids)

        void setMeshEdge (const char* meshName, int firstVertexID, int secondVertexID)

        void setMeshEdges (const char* meshName, const int* vertices)

        void setMeshTriangle (const char* meshName, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshTriangles (const char* meshName, const int* vertices)

        void setMeshQuad (const char* meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshQuads (const char* meshName, const int* vertices)

        void setMeshTetrahedron (const char* meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshTetrahedra (const char* meshName, )

        # data access

        bool hasData (const char* dataName, const char* meshName) const

        void writeData (const char* meshName, const char* dataName, const int* vertices, const double* values)

        void readData (const char* meshName, const char* dataName, const int* vertices, const double relativeReadTime, double* values) const

        # Gradient related API

        bool requiresGradientDataFor(const char* meshName, const char* dataName) const

        void writeGradientData(const char* meshName, const char* dataName, const int* vertices, const double* gradientValues)

        # direct mesh access

        void setMeshAccessRegion (const char* meshName, const double* boundingBox) const

        void getMeshVerticesAndIDs (const char* meshName, int* ids, double* coordinates) const

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
