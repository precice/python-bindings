from libcpp        cimport bool
from libcpp.set    cimport set
from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "precice/precice.hpp" namespace "precice":
    cdef cppclass Participant:
        # construction and configuration

        Participant (const string&, const string&, int, int) except +

        Participant (const string&, const string&, int, int, void*) except +

        # steering methods

        void initialize () except +

        void advance (double computedTimestepLength) except +

        void finalize()

        # status queries

        int getMeshDimensions(const string& meshName) except +

        int getDataDimensions(const string& meshName, const string& dataName) except +

        bool isCouplingOngoing()

        bool isTimeWindowComplete()

        double getMaxTimeStepSize()

        bool requiresInitialData()

        bool requiresWritingCheckpoint()

        bool requiresReadingCheckpoint()

        # mesh access

        bool requiresMeshConnectivityFor (const string& meshName) except +

        int setMeshVertex (const string& meshName, vector[double] position) except +

        int getMeshVertexSize (const string& meshName) except +

        void setMeshVertices (const string& meshName, vector[double] positions, vector[int]& ids) except +

        void setMeshEdge (const string& meshName, int firstVertexID, int secondVertexID) except +

        void setMeshEdges (const string& meshName, vector[int] vertices) except +

        void setMeshTriangle (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID) except +

        void setMeshTriangles (const string& meshName, vector[int] vertices) except +

        void setMeshQuad (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID) except +

        void setMeshQuads (const string& meshName, vector[int] vertices) except +

        void setMeshTetrahedron (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID) except +

        void setMeshTetrahedra (const string& meshName, vector[int] vertices) except +

        # remeshing

        void resetMesh (const string& meshName) except +

        # data access

        void writeData (const string& meshName, const string& dataName, vector[int] vertices, vector[double] values) except +

        void readData (const string& meshName, const string& dataName, vector[int] vertices, const double relativeReadTime, vector[double]& values) except +

        # Just-in-time mapping
        
        void writeAndMapData (const string& meshName, const string& dataName, vector[double] coordinates, vector[double] values) except +

        void mapAndReadData  (const string& meshName, const string& dataName, vector[double] coordinates, double relativeReadTime, vector[double]& values) except +

        # direct access

        void setMeshAccessRegion (const string& meshName, vector[double] boundingBox) except +

        void getMeshVertexIDsAndCoordinates (const string& meshName, vector[int]& ids, vector[double]& coordinates) except +

        # Gradient related API

        bool requiresGradientDataFor(const string& meshName, const string& dataName) except +

        void writeGradientData(const string& meshName, const string& dataName, vector[int] vertices, vector[double] gradientValues) except +

        # Experimental profiling API

        void startProfilingSection(const string& eventName)

        void stopLastProfilingSection()

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
