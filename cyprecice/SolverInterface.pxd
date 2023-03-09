from libcpp        cimport bool
from libcpp.set    cimport set
from libcpp.string cimport string

cdef extern from "<string_view>" namespace "std":
    pass


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

        bool hasMesh (string_view meshName ) const

        int getMeshID (string_view meshName) const

        bool requiresMeshConnectivityFor (string_view meshName) const

        int setMeshVertex (string_view meshName, const double* position)

        int getMeshVertexSize (string_view meshName) const

        void setMeshVertices (string_view meshName, int size, const double* positions, int* ids)

        void setMeshEdge (string_view meshName, int firstVertexID, int secondVertexID)

        void setMeshEdges (string_view meshName, int size, const int* vertices)

        void setMeshTriangle (string_view meshName, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshTriangles (string_view meshName, int size, const int* vertices)

        void setMeshQuad (string_view meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshQuads (string_view meshName, int size, const int* vertices)

        # data access

        bool hasData (string_view dataName, string_view meshName) const

        int getDataID (string_view dataName, string_view meshName) const

        void writeBlockVectorData (string_view meshName, string_view dataName, const int size, const int* valueIndices, const double* values)

        void writeVectorData (string_view meshName, string_view dataName, const int valueIndex, const double* value)

        void writeBlockScalarData (string_view meshName, string_view dataName, const int size, const int* valueIndices, const double* values)

        void writeScalarData (string_view meshName, string_view dataName, const int valueIndex, const double value)

        void readBlockVectorData (string_view meshName, string_view dataName, const int size, const int* valueIndices, double* values) const

        void readBlockVectorData (string_view meshName, string_view dataName, const int size, const int* valueIndices, double relativeReadTime, double* values) const

        void readVectorData (string_view meshName, string_view dataName, const int valueIndex, double* value) const

        void readVectorData (string_view meshName, string_view dataName, const int valueIndex, double relativeReadTime, double* value) const

        void readBlockScalarData (string_view meshName, string_view dataName, const int size, const int* valueIndices, double* values) const

        void readBlockScalarData (string_view meshName, string_view dataName, const int size, const int* valueIndices, double relativeReadTime, double* values) const

        void readScalarData (string_view meshName, string_view dataName, const int valueIndex, double& value) const

        void readScalarData (string_view meshName, string_view dataName, const int valueIndex, double relativeReadTime, double& value) const

        # Gradient related API

        bool requiresGradientDataFor(string_view meshName, string_view dataName) const

        void writeBlockVectorGradientData(string_view meshName, string_view dataName, int size, const int* valueIndices, const double* gradientValues)

        void writeScalarGradientData(string_view meshName, string_view dataName, int valueIndex, const double* gradientValues)

        void writeVectorGradientData(string_view meshName, string_view dataName, int valueIndex, const double* gradientValues)

        void writeBlockScalarGradientData(string_view meshName, string_view dataName, int size, const int* valueIndices, const double* gradientValues)

        # direct mesh access

        void setMeshAccessRegion (string_view meshName, const double* boundingBox) const

        void getMeshVerticesAndIDs (string_view meshName, const int size, int* ids, double* coordinates) const

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
