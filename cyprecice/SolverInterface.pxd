from libcpp        cimport bool
from libcpp.set    cimport set
from libcpp.string cimport string

cdef extern from "<string_view>" namespace "std":
    cdef cppclass string_view:
        string_view() except +
        string_view(const string&) except +  # necessary to cast Python strings to string_view before handing over to C++ API


cdef extern from "precice/SolverInterface.hpp" namespace "precice":
    cdef cppclass SolverInterface:
        # construction and configuration

        SolverInterface (const string&, const string&, int, int) except +

        SolverInterface (const string&, const string&, int, int, void*) except +

        void configure (const string&)

        # steering methods

        double initialize ()

        double advance (double computedTimestepLength)

        void finalize()

        # status queries

        int getDimensions() const

        bool isCouplingOngoing() const

        bool isTimeWindowComplete() const

        bool requiresInitialData()

        bool requiresReadingCheckpoint()

        bool requiresWritingCheckpoint()

        # mesh access

        bool hasMesh (const char* meshName) const

        bool requiresMeshConnectivityFor (const char* meshName) const

        int setMeshVertex (const char* meshName, const double* position)

        int getMeshVertexSize (const char* meshName) const

        void setMeshVertices (const char* meshName, int size, const double* positions, int* ids)

        void setMeshEdge (const char* meshName, int firstVertexID, int secondVertexID)

        void setMeshEdges (const char* meshName, int size, const int* vertices)

        void setMeshTriangle (const char* meshName, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshTriangles (const char* meshName, int size, const int* vertices)

        void setMeshQuad (const char* meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshQuads (const char* meshName, int size, const int* vertices)

        # data access

        bool hasData (const char* dataName, const char* meshName) const

        void writeBlockVectorData (const char* meshName, const char* dataName, const int size, const int* valueIndices, const double* values)

        void writeVectorData (const char* meshName, const char* dataName, const int valueIndex, const double* value)

        void writeBlockScalarData (const char* meshName, const char* dataName, const int size, const int* valueIndices, const double* values)

        void writeScalarData (const char* meshName, const char* dataName, const int valueIndex, const double value)

        void readBlockVectorData (const char* meshName, const char* dataName, const int size, const int* valueIndices, double* values) const

        void readBlockVectorData (const char* meshName, const char* dataName, const int size, const int* valueIndices, double relativeReadTime, double* values) const

        void readVectorData (const char* meshName, const char* dataName, const int valueIndex, double* value) const

        void readVectorData (const char* meshName, const char* dataName, const int valueIndex, double relativeReadTime, double* value) const

        void readBlockScalarData (const char* meshName, const char* dataName, const int size, const int* valueIndices, double* values) const

        void readBlockScalarData (const char* meshName, const char* dataName, const int size, const int* valueIndices, double relativeReadTime, double* values) const

        void readScalarData (const char* meshName, const char* dataName, const int valueIndex, double& value) const

        void readScalarData (const char* meshName, const char* dataName, const int valueIndex, double relativeReadTime, double& value) const

        # Gradient related API

        bool requiresGradientDataFor(const char* meshName, const char* dataName) const

        void writeBlockVectorGradientData(const char* meshName, const char* dataName, int size, const int* valueIndices, const double* gradientValues)

        void writeScalarGradientData(const char* meshName, const char* dataName, int valueIndex, const double* gradientValues)

        void writeVectorGradientData(const char* meshName, const char* dataName, int valueIndex, const double* gradientValues)

        void writeBlockScalarGradientData(const char* meshName, const char* dataName, int size, const int* valueIndices, const double* gradientValues)

        # direct mesh access

        void setMeshAccessRegion (const char* meshName, const double* boundingBox) const

        void getMeshVerticesAndIDs (const char* meshName, const int size, int* ids, double* coordinates) const

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
