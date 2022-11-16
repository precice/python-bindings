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

        void initializeData ()

        double advance (double computedTimestepLength)

        void finalize()

        # status queries

        int getDimensions() const

        bool isCouplingOngoing() const

        bool isReadDataAvailable() const

        bool isWriteDataRequired (double computedTimestepLength) const

        bool isTimeWindowComplete() const

        bool hasToEvaluateSurrogateModel () const

        bool hasToEvaluateFineModel () const

        # action methods

        bool isActionRequired (const string& action) const

        void markActionFulfilled (const string& action)

        # mesh access

        bool hasMesh (const string& meshName ) const

        int getMeshID (const string& meshName) const

        set[int] getMeshIDs ()

        bool isMeshConnectivityRequired (int meshID) const

        int setMeshVertex (int meshID, const double* position)

        int getMeshVertexSize (int meshID) const

        void setMeshVertices (int meshID, int size, const double* positions, int* ids)

        void getMeshVertices (int meshID, int size, const int* ids, double* positions) const

        int setMeshEdge (int meshID, int firstVertexID, int secondVertexID)

        void setMeshTriangle (int meshID, int firstEdgeID, int secondEdgeID, int thirdEdgeID)

        void setMeshTriangleWithEdges (int meshID, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshQuad (int meshID, int firstEdgeID, int secondEdgeID, int thirdEdgeID, int fourthEdgeID)

        void setMeshQuadWithEdges (int meshID, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        # data access

        bool hasData (const string& dataName, int meshID) const

        int getDataID (const string& dataName, int meshID) const

        void mapReadDataTo (int toMeshID)

        void mapWriteDataFrom (int fromMeshID)

        void writeBlockVectorData (const int dataID, const int size, const int* valueIndices, const double* values)

        void writeVectorData (const int dataID, const int valueIndex, const double* value)

        void writeBlockScalarData (const int dataID, const int size, const int* valueIndices, const double* values)

        void writeScalarData (const int dataID, const int valueIndex, const double value)

        void readBlockVectorData (const int dataID, const int size, const int* valueIndices, double* values) const

        void readVectorData (const int dataID, const int valueIndex, double* value) const

        void readBlockScalarData (const int dataID, const int size, const int* valueIndices, double* values) const

        void readScalarData (const int dataID, const int valueIndex, double& value) const

        # Gradient related API 

        bool isGradientDataRequired(int dataID) const;

        void writeBlockVectorGradientData(int dataID, int size, const int* valueIndices, const double* gradientValues);

        void writeScalarGradientData(int dataID, int valueIndex, const double* gradientValues);

        void writeVectorGradientData(int dataID, int valueIndex, const double* gradientValues);

        void writeBlockScalarGradientData(int dataID, int size, const int* valueIndices, const double* gradientValues);

        # direct mesh access

        void setMeshAccessRegion (const int meshID, const double* boundingBox) const

        void getMeshVerticesAndIDs (const int meshID, const int size, int* ids, double* coordinates) const

cdef extern from "precice/SolverInterface.hpp" namespace "precice":
    string getVersionInformation()

cdef extern from "precice/SolverInterface.hpp"  namespace "precice::constants":
    const string& actionWriteInitialData()
    const string& actionWriteIterationCheckpoint()
    const string& actionReadIterationCheckpoint()
