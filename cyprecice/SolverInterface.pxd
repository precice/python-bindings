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

        set[int] getMeshIDs ()

        bool requiresMeshConnectivityFor (int meshID) const

        int setMeshVertex (int meshID, const double* position)

        int getMeshVertexSize (int meshID) const

        void setMeshVertices (int meshID, int size, const double* positions, int* ids)

        void setMeshEdge (int meshID, int firstVertexID, int secondVertexID)

        void setMeshEdges (int meshID, int size, const int* vertices)

        void setMeshTriangle (int meshID, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshTriangles (int meshID, int size, const int* vertices)

        void setMeshQuad (int meshID, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshQuads (int meshID, int size, const int* vertices)

        # data access

        bool hasData (const string& dataName, int meshID) const

        int getDataID (const string& dataName, int meshID) const

        void writeBlockVectorData (const int dataID, const int size, const int* valueIndices, const double* values)

        void writeVectorData (const int dataID, const int valueIndex, const double* value)

        void writeBlockScalarData (const int dataID, const int size, const int* valueIndices, const double* values)

        void writeScalarData (const int dataID, const int valueIndex, const double value)

        void readBlockVectorData (const int dataID, const int size, const int* valueIndices, double* values) const

        void readBlockVectorData (const int dataID, const int size, const int* valueIndices, double dt, double* values) const

        void readVectorData (const int dataID, const int valueIndex, double* value) const

        void readVectorData (const int dataID, const int valueIndex, double dt, double* value) const

        void readBlockScalarData (const int dataID, const int size, const int* valueIndices, double* values) const

        void readBlockScalarData (const int dataID, const int size, const int* valueIndices, double dt, double* values) const

        void readScalarData (const int dataID, const int valueIndex, double& value) const

        void readScalarData (const int dataID, const int valueIndex, double dt, double& value) const

        # Gradient related API 

        bool requiresGradientDataFor(int dataID) const

        void writeBlockVectorGradientData(int dataID, int size, const int* valueIndices, const double* gradientValues)

        void writeScalarGradientData(int dataID, int valueIndex, const double* gradientValues)

        void writeVectorGradientData(int dataID, int valueIndex, const double* gradientValues)

        void writeBlockScalarGradientData(int dataID, int size, const int* valueIndices, const double* gradientValues)

        # direct mesh access

        void setMeshAccessRegion (const int meshID, const double* boundingBox) const

        void getMeshVerticesAndIDs (const int meshID, const int size, int* ids, double* coordinates) const

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
