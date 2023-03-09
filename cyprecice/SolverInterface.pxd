from libcpp        cimport bool
from libcpp.set    cimport set
from libcpp.string cimport string


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

        bool hasMesh (const string& meshName ) const

        int getMeshID (const string& meshName) const

        bool requiresMeshConnectivityFor (const string& meshName) const

        int setMeshVertex (const string& meshName, const double* position)

        int getMeshVertexSize (const string& meshName) const

        void setMeshVertices (const string& meshName, int size, const double* positions, int* ids)

        void setMeshEdge (const string& meshName, int firstVertexID, int secondVertexID)

        void setMeshEdges (const string& meshName, int size, const int* vertices)

        void setMeshTriangle (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshTriangles (const string& meshName, int size, const int* vertices)

        void setMeshQuad (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshQuads (const string& meshName, int size, const int* vertices)

        # data access

        bool hasData (const string& dataName, const string& meshName) const

        int getDataID (const string& dataName, const string& meshName) const

        void writeBlockVectorData (const string& meshName, const string& dataName, const int size, const int* valueIndices, const double* values)

        void writeVectorData (const string& meshName, const string& dataName, const int valueIndex, const double* value)

        void writeBlockScalarData (const string& meshName, const string& dataName, const int size, const int* valueIndices, const double* values)

        void writeScalarData (const string& meshName, const string& dataName, const int valueIndex, const double value)

        void readBlockVectorData (const string& meshName, const string& dataName, const int size, const int* valueIndices, double* values) const

        void readBlockVectorData (const string& meshName, const string& dataName, const int size, const int* valueIndices, double relativeReadTime, double* values) const

        void readVectorData (const string& meshName, const string& dataName, const int valueIndex, double* value) const

        void readVectorData (const string& meshName, const string& dataName, const int valueIndex, double relativeReadTime, double* value) const

        void readBlockScalarData (const string& meshName, const string& dataName, const int size, const int* valueIndices, double* values) const

        void readBlockScalarData (const string& meshName, const string& dataName, const int size, const int* valueIndices, double relativeReadTime, double* values) const

        void readScalarData (const string& meshName, const string& dataName, const int valueIndex, double& value) const

        void readScalarData (const string& meshName, const string& dataName, const int valueIndex, double relativeReadTime, double& value) const

        # Gradient related API

        bool requiresGradientDataFor(const string& meshName, const string& dataName) const

        void writeBlockVectorGradientData(const string& meshName, const string& dataName, int size, const int* valueIndices, const double* gradientValues)

        void writeScalarGradientData(const string& meshName, const string& dataName, int valueIndex, const double* gradientValues)

        void writeVectorGradientData(const string& meshName, const string& dataName, int valueIndex, const double* gradientValues)

        void writeBlockScalarGradientData(const string& meshName, const string& dataName, int size, const int* valueIndices, const double* gradientValues)

        # direct mesh access

        void setMeshAccessRegion (const const string& meshName, const double* boundingBox) const

        void getMeshVerticesAndIDs (const const string& meshName, const int size, int* ids, double* coordinates) const

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
