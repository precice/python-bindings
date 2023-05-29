from libcpp        cimport bool
from libcpp.set    cimport set
from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "precice/Participant.hpp" namespace "precice":
    cdef cppclass Participant:
        # construction and configuration

        Participant (const string&, const string&, int, int) except +

        Participant (const string&, const string&, int, int, void*) except +

        void configure (const string&)

        # steering methods

        void initialize ()

        void advance (double computedTimestepLength)

        void finalize()

        # status queries

        int getMeshDimensions(const string& meshName) const

        int getDataDimensions(const string& meshName, const string& dataName) const

        bool isCouplingOngoing() const

        bool isTimeWindowComplete() const

        double getMaxTimeStepSize() const

        bool requiresInitialData()

        bool requiresReadingCheckpoint()

        bool requiresWritingCheckpoint()

        # mesh access

        bool hasMesh (const string& meshName) const

        bool requiresMeshConnectivityFor (const string& meshName) const

        int setMeshVertex (const string& meshName, vector[double] position)

        int getMeshVertexSize (const string& meshName) const

        void setMeshVertices (const string& meshName, vector[double] positions, vector[int]& ids)

        void setMeshEdge (const string& meshName, int firstVertexID, int secondVertexID)

        void setMeshEdges (const string& meshName, vector[int] vertices)

        void setMeshTriangle (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID)

        void setMeshTriangles (const string& meshName, vector[int] vertices)

        void setMeshQuad (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshQuads (const string& meshName, vector[int] vertices)

        void setMeshTetrahedron (const string& meshName, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)

        void setMeshTetrahedra (const string& meshName, )

        # data access

        bool hasData (const string& dataName, const string& meshName) const

        void writeData (const string& meshName, const string& dataName, vector[int] vertices, vector[double] values)

        void readData (const string& meshName, const string& dataName, vector[int] vertices, const double relativeReadTime, vector[double]& values) const

        # Gradient related API

        bool requiresGradientDataFor(const string& meshName, const string& dataName) const

        void writeGradientData(const string& meshName, const string& dataName, vector[int] vertices, vector[double] gradientValues)

        # direct mesh access

        void setMeshAccessRegion (const string& meshName, vector[double] boundingBox) const

        void getMeshVerticesAndIDs (const string& meshName, vector[int]& ids, vector[double]& coordinates) const

cdef extern from "precice/Tooling.hpp" namespace "precice":
    string getVersionInformation()
