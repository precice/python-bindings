# distutils: language = c++

"""precice

The python module precice offers python language bindings to the C++ coupling library precice. Please refer to precice.org for further information.
"""

import numpy as np
cimport numpy as np
cimport cython
from mpi4py import MPI


from cpython.version cimport PY_MAJOR_VERSION  # important for determining python version in order to properly normalize string input. See http://docs.cython.org/en/latest/src/tutorial/strings.html#general-notes-about-c-strings and https://github.com/precice/precice/issues/68 .

cdef bytes convert(s):
    """
    source code from http://docs.cython.org/en/latest/src/tutorial/strings.html#general-notes-about-c-strings
    """
    if type(s) is bytes:
        return s
    elif type(s) is str:
        return s.encode()
    else:
        raise TypeError("Could not convert.")


@cython.embedsignature(True)
cdef class Interface:
    """
    Main Application Programming Interface of preCICE.
    To adapt a solver to preCICE, follow the following main structure:
        - Create an object of SolverInterface with Interface()
        - Configure the object with Interface::configure()
        - Initialize preCICE with Interface::initialize()
        - Advance to the next (time)step with Interface::advance()
        - Finalize preCICE with Interface::finalize()
        - We use solver, simulation code, and participant as synonyms.
        - The preferred name in the documentation is participant.
    """

    # fake __init__ needed to display docstring for __cinit__ (see https://stackoverflow.com/a/42733794/5158031)
    def __init__(self, solver_name, configuration_file_name, solver_process_index, solver_process_size, communicator=None):
        """
        Constructor of Interface class.

        Parameters
        ----------
        solver_name : string
            Name of the solver
        configuration_file_name : string
            Name of the preCICE config file
        solver_process_index : int
            Rank of the process
        solver_process_size : int
            Size of the process

        Returns
        -------
        SolverInterface : object
            Object pointing to the defined coupling interface

        Example
        -------
        >>> interface = precice.Interface("SolverOne", "precice-config.xml", 0, 1)
        preCICE: This is preCICE version X.X.X
        preCICE: Revision info: vX.X.X-X-XXXXXXXXX
        preCICE: Configuring preCICE with configuration: "precice-config.xml"

        """
        pass

    def __cinit__ (self, solver_name, configuration_file_name, solver_process_index, solver_process_size, communicator=None):
        cdef void* communicator_ptr
        if communicator:
            communicator_ptr = <void*> communicator
            self.thisptr = new SolverInterface.SolverInterface (convert(solver_name), convert(configuration_file_name), solver_process_index, solver_process_size, communicator_ptr)
        else:
            self.thisptr = new SolverInterface.SolverInterface (convert(solver_name), convert(configuration_file_name), solver_process_index, solver_process_size)
        pass

    def __dealloc__ (self):
        """
        Destructor of Interface class
        """
        del self.thisptr

    # steering methods

    def initialize (self):
        """
        Fully initializes preCICE.
        This function handles:
            - Parallel communication to the coupling partner/s is setup.
            - Meshes are exchanged between coupling partners and the parallel partitions are created.
            - [Serial Coupling Scheme] If the solver is not starting the simulation, coupling data is received
                                       from the coupling partner's first computation.

        Returns
        -------
        max_timestep : double
            Maximum length of first timestep to be computed by the solver.
        """
        return self.thisptr.initialize ()

    def initialize_data (self):
        """
        Initializes coupling data. The starting values for coupling data are zero by default.
        To provide custom values, first set the data using the Data Access methods and
        call this method to finally exchange the data.

        Serial Coupling Scheme: Only the first participant has to call this method, the second participant
            receives the values on calling initialize().

        Parallel Coupling Scheme:
            - Values in both directions are exchanged.
            - Both participants need to call initializeData().

        Notes
        -----
        Previous calls:
            initialize() has been called successfully.
            The action WriteInitialData is required
            advance() has not yet been called.
            finalize() has not yet been called.

        Tasks completed:
            Initial coupling data was exchanged.
        """
        self.thisptr.initializeData ()


    def advance (self, double computed_timestep_length):
        """
        Advances preCICE after the solver has computed one timestep.

        Parameters
        ----------
        computed_timestep_length : double
            Length of timestep used by the solver.

        Returns
        -------
        max_timestep : double
            Maximum length of next timestep to be computed by solver.

        Notes
        -----
        Previous calls:
            initialize() has been called successfully.
            The solver has computed one timestep.
            The solver has written all coupling data.
            finalize() has not yet been called.

        Tasks completed:
            Coupling data values specified in the configuration are exchanged.
            Coupling scheme state (computed time, computed timesteps, ...) is updated.
            The coupling state is logged.
            Configured data mapping schemes are applied.
            [Second Participant] Configured post processing schemes are applied.
            Meshes with data are exported to files if configured.
        """
        return self.thisptr.advance (computed_timestep_length)


    def finalize (self):
        """
        Finalizes preCICE.

        Notes
        -----
        Previous calls:
            initialize() has been called successfully.

        Tasks completed:
            Communication channels are closed.
            Meshes and data are deallocated.
        """
        self.thisptr.finalize ()

    # status queries

    def get_dimensions (self):
        """
        Returns the number of spatial dimensions configured. Currently, two and three dimensional problems
        can be solved using preCICE. The dimension is specified in the XML configuration.

        Returns
        -------
        dimension : int
            The configured dimension.
        """
        return self.thisptr.getDimensions ()


    def is_coupling_ongoing (self):
        """
        Checks if the coupled simulation is still ongoing.
        A coupling is ongoing as long as
            - the maximum number of timesteps has not been reached, and
            - the final time has not been reached.
        The user should call finalize() after this function returns false.

        Returns
        -------
        tag : bool
            Whether the coupling is ongoing.

        Notes
        -----
        Previous calls:
           initialize() has been called successfully.
        """
        return self.thisptr.isCouplingOngoing ()


    def is_read_data_available (self):
        """
        Checks if new data to be read is available. Data is classified to be new, if it has been received
        while calling initialize() and before calling advance(), or in the last call of advance().
        This is always true, if a participant does not make use of subcycling, i.e. choosing smaller
        timesteps than the limits returned in intitialize() and advance().

        It is allowed to read data even if this function returns false. This is not recommended
        due to performance reasons. Use this function to prevent unnecessary reads.

        Returns
        -------
        tag : bool
            Whether new data is available to be read.

        Notes
        -----
        Previous calls:
           initialize() has been called successfully.
        """
        return self.thisptr.isReadDataAvailable ()


    def is_write_data_required (self, double computed_timestep_length):
        """
        Checks if new data has to be written before calling advance().
        This is always true, if a participant does not make use of subcycling, i.e. choosing smaller
        timesteps than the limits returned in intitialize() and advance().

        It is allowed to write data even if this function returns false. This is not recommended
        due to performance reasons. Use this function to prevent unnecessary writes.

        Parameters
        ----------
        computed_timestep_length : double
            Length of timestep used by the solver.

        Returns
        -------
        tag : bool
            Whether new data has to be written.

        Notes
        -----
        Previous calls:
            initialize() has been called successfully.
        """
        return self.thisptr.isWriteDataRequired (computed_timestep_length)


    def is_time_window_complete (self):
        """
        Checks if the current coupling timewindow is completed.
        The following reasons require several solver time steps per coupling time step:
            - A solver chooses to perform subcycling.
            - An implicit coupling timestep iteration is not yet converged.

        Returns
        -------
            tag : bool
                Whether the timestep is complete.

        Notes
        -----
        Previous calls:
            initialize() has been called successfully.
        """
        return self.thisptr.isTimeWindowComplete ()


    def has_to_evaluate_surrogate_model (self):
        """
        Returns whether the solver has to evaluate the surrogate model representation.
        The solver may still have to evaluate the fine model representation.
        DEPRECATED: Only necessary for deprecated manifold mapping.

        Returns
        -------
            tag : bool
                Whether the surrogate model has to be evaluated.
        """
        return self.thisptr.hasToEvaluateSurrogateModel ()


    def has_to_evaluate_fine_model (self):
        """
        Checks if the solver has to evaluate the fine model representation.
        The solver may still have to evaluate the surrogate model representation.
        DEPRECATED: Only necessary for deprecated manifold mapping.

        Returns
        -------
        tag : bool
            Whether the fine model has to be evaluated.
        """
        return self.thisptr.hasToEvaluateFineModel ()

    # action methods

    def is_action_required (self, action):
        """
        Checks if the provided action is required.
        Some features of preCICE require a solver to perform specific actions, in order to be
        in valid state for a coupled simulation. A solver is made eligible to use those features,
        by querying for the required actions, performing them on demand, and calling markActionfulfilled()
        to signalize preCICE the correct behavior of the solver.

        Parameters
        ----------
        action : preCICE action
            Name of the action.

        Returns
        -------
        tag : bool
            Returns True if action is required.
        """
        return self.thisptr.isActionRequired (action)


    def mark_action_fulfilled (self, action):
        """
        Indicates preCICE that a required action has been fulfilled by a solver.

        Parameters
        ----------
        action : preCICE action
            Name of the action.

        Notes
        -----
        Previous calls:
            The solver fulfilled the specified action.
        """
        self.thisptr.markActionFulfilled (action)

    # mesh access

    def has_mesh(self, mesh_name):
        """
        Checks if the mesh with the given name is used by a solver.

        Parameters
        ----------
        mesh_name : string
            Name of the mesh.

        Returns
        -------
        tag : bool
            Returns true is the mesh is used.
        """
        return self.thisptr.hasMesh (convert(mesh_name))


    def get_mesh_id (self, mesh_name):
        """
        Returns the ID belonging to the mesh with given name.

        Parameters
        ----------
        mesh_name : string
            Name of the mesh.

        Returns
        -------
        id : int
            ID of the corresponding mesh.

        Example
        -------
        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> mesh_id
        0

        """
        return self.thisptr.getMeshID (convert(mesh_name))


    def get_mesh_ids (self):
        """
        Returns the ID-set of all used meshes by this participant.

        Returns
        -------
        id_array : numpy.array
            Numpy array containing all IDs.
        """
        return self.thisptr.getMeshIDs ()


    def get_mesh_handle(self, mesh_name):
        """
        Returns a handle to a created mesh.
        WARNING: This function is not yet available for the Python bindings

        Parameters
        ----------
        mesh_name : string
            Name of the mesh.

        Returns
        -------
        tag : object
            Handle to the mesh.
        """
        raise Exception("The API method get_mesh_handle is not yet available for the Python bindings.")


    def set_mesh_vertex(self, mesh_id, position):
        """
        Creates a mesh vertex

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the vertex to.
        position : array_like
            The coordinates of the vertex.

        Returns
        -------
        vertex_id : int
            ID of the vertex which is set.

        Notes
        -----
        Previous calls:
            Count of available elements at position matches the configured dimension
        """
        if not isinstance(position, np.ndarray):
            position = np.asarray(position)
        dimensions = position.size
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[double, ndim=1] _position = np.ascontiguousarray(position, dtype=np.double)
        vertex_id = self.thisptr.setMeshVertex(mesh_id, <const double*>_position.data)
        return vertex_id

    def get_mesh_vertex_size (self, mesh_id):
        """
        Returns the number of vertices of a mesh

        Parameters
        ----------
        mesh_id : int
            ID of the mesh.

        Returns
        -------
        sum : int
            Number of vertices of the mesh.
        """
        return self.thisptr.getMeshVertexSize(mesh_id)

    def set_mesh_vertices (self, mesh_id, positions):
        """
        Creates multiple mesh vertices

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the vertices to.
        positions : array_like
            The coordinates of the vertices in a numpy array [N x D] where
            N = number of vertices and D = dimensions of geometry.

        Returns
        -------
        vertex_ids : numpy.array
            IDs of the created vertices.

        Notes
        -----
        Previous calls:
            initialize() has not yet been called
            count of available elements at positions matches the configured dimension * size
            count of available elements at ids matches size

        Examples
        --------
        Set mesh vertices for a 2D problem with 5 mesh vertices.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> positions = np.array([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])
        >>> positions.shape
        (5, 2)
        >>> vertex_ids = interface.set_mesh_vertices(mesh_id, positions)
        >>> vertex_ids.shape
        (5,)

        Set mesh vertices for a 3D problem with 5 mesh vertices.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> positions = np.array([[1, 1, 1], [2, 2, 2], [3, 3, 3], [4, 4, 4], [5, 5, 5]])
        >>> positions.shape
        (5, 3)
        >>> vertex_ids = interface.set_mesh_vertices(mesh_id, positions)
        >>> vertex_ids.shape
        (5,)
        """
        if not isinstance(positions, np.ndarray):
            positions = np.asarray(positions)
        size, dimensions = positions.shape
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[double, ndim=1] _positions = np.ascontiguousarray(positions.flatten(), dtype=np.double)
        cdef np.ndarray[int, ndim=1] vertex_ids = np.empty(size, dtype=np.int32)
        self.thisptr.setMeshVertices (mesh_id, size, <const double*>_positions.data, <int*>vertex_ids.data)
        return vertex_ids

    def get_mesh_vertices(self, mesh_id, vertex_ids):
        """
        Get vertex positions for multiple vertex ids from a given mesh

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to read the vertices from.
        vertex_ids : array_like
            IDs of the vertices to lookup.

        Returns
        -------
        positions : numpy.ndarray
            The coordinates of the vertices in a numpy array [N x D] where
            N = number of vertices and D = dimensions of geometry

        Notes
        -----
        Previous calls:
            count of available elements at positions matches the configured dimension * size
            count of available elements at ids matches size

        Examples
        --------
        Return data structure for a 2D problem with 5 vertices:
        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> positions = interface.get_mesh_vertices(mesh_id, vertex_ids)
        >>> positions.shape
        (5, 2)

        Return data structure for a 3D problem with 5 vertices:
        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> positions = interface.get_mesh_vertices(mesh_id, vertex_ids)
        >>> positions.shape
        (5, 3)
        """
        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        size = _vertex_ids.size
        cdef np.ndarray[double, ndim=1] _positions = np.empty(size * self.get_dimensions(), dtype=np.double)
        self.thisptr.getMeshVertices (mesh_id, size, <const int*>_vertex_ids.data, <double*>_positions.data)
        return _positions.reshape((size, self.get_dimensions()))

    def get_mesh_vertex_ids_from_positions (self, mesh_id, positions):
        """
        Gets mesh vertex IDs from positions.
        prefer to reuse the IDs returned from calls to set_mesh_vertex() and set_mesh_vertices().

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to retrieve positions from.
        positions : numpy.ndarray
            The coordinates of the vertices. Coordinates of vertices are stored in a
            numpy array [N x D] where N = number of vertices and D = dimensions of geometry

        Returns
        -------
        vertex_ids : numpy.array
            IDs of mesh vertices.

        Notes
        -----
        Previous calls:
            count of available elements at positions matches the configured dimension * size
            count of available elements at ids matches size

        Examples
        --------
        Get mesh vertex ids from positions for a 2D (D=2) problem with 5 (N=5) mesh vertices.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> positions = np.array([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])
        >>> positions.shape
        (5, 2)
        >>> vertex_ids = interface.get_mesh_vertex_ids_from_positions(mesh_id, positions)
        >>> vertex_ids
        array([1, 2, 3, 4, 5])

        Get mesh vertex ids from positions for a 3D problem with 5 vertices.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> positions = np.array([[1, 1, 1], [2, 2, 2], [3, 3, 3], [4, 4, 4], [5, 5, 5]])
        >>> positions.shape
        (5, 3)
        >>> vertex_ids = interface.get_mesh_vertex_ids_from_positions(mesh_id, positions)
        >>> vertex_ids
        array([1, 2, 3, 4, 5])
        """
        if not isinstance(positions, np.ndarray):
            positions = np.asarray(positions)
        size, dimensions = positions.shape
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[double, ndim=1] _positions = np.ascontiguousarray(positions.flatten(), dtype=np.double)
        cdef np.ndarray[int, ndim=1] vertex_ids = np.empty(int(size), dtype=np.int32)
        self.thisptr.getMeshVertexIDsFromPositions (mesh_id, size, <const double*>_positions.data, <int*>vertex_ids.data)
        return vertex_ids

    def set_mesh_edge (self, mesh_id, first_vertex_id, second_vertex_id):
        """
        Sets mesh edge from vertex IDs, returns edge ID.

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the edge to.
        firstVertexID : int
            ID of the first vertex of the edge.
        secondVertexID : int
            ID of the second vertex of the edge.

        Returns
        -------
        edge_id : int
            ID of the edge.

        Notes
        -----
        Previous calls:
            vertices with firstVertexID and secondVertexID were added to the mesh with the ID meshID
        """
        return self.thisptr.setMeshEdge (mesh_id, first_vertex_id, second_vertex_id)

    def set_mesh_triangle (self, mesh_id, first_edge_id, second_edge_id, third_edge_id):
        """
        Sets mesh triangle from edge IDs

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the triangle to.
        first_edge_id : int
            ID of the first edge of the triangle.
        second_edge_id : int
            ID of the second edge of the triangle.
        third_edge_id : int
            ID of the third edge of the triangle.

        Notes
        -----
        Previous calls:
            edges with first_edge_id, second_edge_id, and third_edge_id were added to the mesh with the ID meshID
        """
        self.thisptr.setMeshTriangle (mesh_id, first_edge_id, second_edge_id, third_edge_id)

    def set_mesh_triangle_with_edges (self, mesh_id, first_vertex_id, second_vertex_id, third_vertex_id):
        """
        Sets mesh triangle from vertex IDs.
        WARNING: This routine is supposed to be used, when no edge information is available per se.
        Edges are created on the fly within preCICE. This routine is significantly slower than the one
        using edge IDs, since it needs to check, whether an edge is created already or not.

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the triangle to.
        first_vertex_id : int
            ID of the first vertex of the triangle.
        second_vertex_id : int
            ID of the second vertex of the triangle.
        third_vertex_id ID : int
            ID of the third vertex of the triangle.

        Notes
        -----
        Previous calls:
            edges with first_vertex_id, second_vertex_id, and third_vertex_id were added to the mesh with the ID meshID
        """
        self.thisptr.setMeshTriangleWithEdges (mesh_id, first_vertex_id, second_vertex_id, third_vertex_id)

    def set_mesh_quad (self, mesh_id, first_edge_id, second_edge_id, third_edge_id, fourth_edge_id):
        """
        Sets mesh Quad from edge IDs.
        WARNING: Quads are not fully implemented yet.

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the Quad to.
        first_edge_id : int
            ID of the first edge of the Quad.
        second_edge_id : int
            ID of the second edge of the Quad.
        third_edge_id : int
            ID of the third edge of the Quad.
        fourth_edge_id : int
            ID of the forth edge of the Quad.

        Notes
        -----
        Previous calls:
            edges with first_edge_id, second_edge_id, third_edge_id, and fourth_edge_id were added
            to the mesh with the ID mesh_id
        """
        self.thisptr.setMeshQuad (mesh_id, first_edge_id, second_edge_id, third_edge_id, fourth_edge_id)

    def set_mesh_quad_with_edges (self, mesh_id, first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id):
        """
        Sets surface mesh quadtriangle from vertex IDs.
        WARNING: This routine is supposed to be used, when no edge information is available per se. Edges are
                 created on the fly within preCICE. This routine is significantly slower than the one using
                 edge IDs, since it needs to check, whether an edge is created already or not.

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the Quad to.
        first_vertex_id : int
            ID of the first vertex of the Quad.
        second_vertex_id : int
            ID of the second vertex of the Quad.
        third_vertex_id : int
            ID of the third vertex of the Quad.
        fourth_vertex_id : int
            ID of the fourth vertex of the Quad.

        Notes
        -----
        Previous calls:
            edges with first_vertex_id, second_vertex_id, third_vertex_id, and fourth_vertex_id were added
            to the mesh with the ID mesh_id
        """
        self.thisptr.setMeshQuadWithEdges (mesh_id, first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id)

    # data access
    def has_data (self, str data_name, mesh_id):
        """
        Checks if the data with given name is used by a solver and mesh.

        Parameters
        ----------
        data_name : string
            Name of the data.
        mesh_id : int
            ID of the associated mesh.

        Returns
        -------
        tag : bool
            True if the mesh is already used.
        """
        return self.thisptr.hasData(convert(data_name), mesh_id)

    def get_data_id (self, str data_name, mesh_id):
        """
        Returns the ID of the data associated with the given name and mesh.

        Parameters
        ----------
        data_name : string
            Name of the data
        mesh_id : int
            ID of the associated mesh.

        Returns
        -------
        data_id : int
            ID of the corresponding data.
        """
        return self.thisptr.getDataID (convert(data_name), mesh_id)

    def map_read_data_to (self, to_mesh_id):
        """
        Computes and maps all read data mapped to the mesh with given ID.
        This is an explicit request to map read data to the Mesh associated with toMeshID.
        It also computes the mapping if necessary.

        Parameters
        ----------
        to_mesh_id : int
            ID of mesh to map the read data to.

        Notes
        -----
        Previous calls:
            A mapping to to_mesh_id was configured.
        """
        self.thisptr.mapReadDataTo (to_mesh_id)

    def map_write_data_from (self, from_mesh_id):
        """
        Computes and maps all write data mapped from the mesh with given ID. This is an explicit request
        to map write data from the Mesh associated with fromMeshID. It also computes the mapping if necessary.

        Parameters
        ----------
        from_mesh_id : int
            ID from which to map write data.

        Notes
        -----
        Previous calls:
            A mapping from from_mesh_id was configured.
        """
        self.thisptr.mapWriteDataFrom (from_mesh_id)

    def write_block_vector_data (self, data_id, vertex_ids, values):
        """
        Writes vector data given as block. This function writes values of specified vertices to a dataID.
        Values are provided as a block of continuous memory. Values are stored in a numpy array [N x D] where N = number
        of vertices and D = dimensions of geometry

        Parameters
        ----------
        data_id : int
            Data ID to write to.
        vertex_ids : array_like
            Indices of the vertices.
        values : numpy.ndarray
            Vector values of data

        Notes
        -----
        Previous calls:
            count of available elements at values matches the configured dimension * size
            count of available elements at vertex_ids matches the given size
            initialize() has been called

        Examples
        --------
        Write block vector data for a 2D problem with 5 vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = np.array([[v1_x, v1_y], [v2_x, v2_y], [v3_x, v3_y], [v4_x, v4_y], [v5_x, v5_y]])
        >>> interface.write_block_vector_data(data_id, vertex_ids, values)

        Write block vector data for a 3D (D=3) problem with 5 (N=5) vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = np.array([[v1_x, v1_y, v1_z], [v2_x, v2_y, v2_z], [v3_x, v3_y, v3_z], [v4_x, v4_y, v4_z], [v5_x, v5_y, v5_z]])
        >>> interface.write_block_vector_data(data_id, vertex_ids, values)
        """
        if not isinstance(values, np.ndarray):
            values = np.asarray(values)
        size, dimensions = values.shape
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _values = np.ascontiguousarray(values.flatten(), dtype=np.double)
        assert(size == _vertex_ids.size)
        self.thisptr.writeBlockVectorData (data_id, size, <const int*>_vertex_ids.data, <const double*>_values.data)

    def write_vector_data (self, data_id, vertex_id, value):
        """
        Writes vector data to a vertex. This function writes a value of a specified vertex to a dataID.
        Values are provided as a block of continuous memory.
        The 2D-format of value is a numpy array of shape 2
        The 3D-format of value is a numpy array of shape 3

        Parameters
        ----------
        data_id : int
            ID to write to.
        vertex_id : int
            Index of the vertex.
        value : numpy.array
            Single vector value

        Notes
        -----
        Previous calls:
            count of available elements at value matches the configured dimension
            initialize() has been called

        Examples
        --------
        Write vector data for a 2D problem with 5 vertices:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> value = np.array([v5_x, v5_y])
        >>> interface.write_vector_data(data_id, vertex_id, value)

        Write vector data for a 3D (D=3) problem with 5 (N=5) vertices:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> value = np.array([v5_x, v5_y, v5_z])
        >>> interface.write_vector_data(data_id, vertex_id, value)
        """
        if not isinstance(value, np.ndarray):
            value = np.asarray(value)
        dimensions = value.size
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[np.double_t, ndim=1] _value = np.ascontiguousarray(value, dtype=np.double)
        self.thisptr.writeVectorData (data_id, vertex_id, <const double*>_value.data)

    def write_block_scalar_data (self, data_id, vertex_ids, values):
        """
        Writes scalar data given as a block. This function writes values of specified vertices to a dataID.

        Parameters
        ----------
        data_id : int
            ID to write to.
        vertex_ids : array_like
            Indices of the vertices.
        values : numpy.array
            Values to be written

        Notes
        -----
        Previous calls:
            count of available elements at values matches the given size
            count of available elements at vertex_ids matches the given size
            initialize() has been called

        Examples
        --------
        Write block scalar data for a 2D and 3D problem with 5 (N=5) vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = np.array([v1 v2, v3, v4, v5])
        >>> interface.write_block_scalar_data(data_id, vertex_ids, values)
        """
        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _values = np.ascontiguousarray(values, dtype=np.double)
        assert(_values.size == _vertex_ids.size)
        size = vertex_ids.size
        self.thisptr.writeBlockScalarData (data_id, size, <const int*>_vertex_ids.data, <const double*>_values.data)

    def write_scalar_data (self, data_id, vertex_id, double value):
        """
        Writes scalar data to a vertex
        This function writes a value of a specified vertex to a dataID.

        Parameters
        ----------
        data_id : int
            ID to write to.
        vertex_id : int
            Index of the vertex.
        value : double
            The value to write.

        Notes
        -----
        Previous calls:
            initialize() has been called

        Examples
        --------
        Write scalar data for a 2D or 3D problem with 5 vertices:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> value = v5
        >>> interface.write_scalar_data(data_id, vertex_id, value)
        """
        self.thisptr.writeScalarData (data_id, vertex_id, value)

    def read_block_vector_data (self, data_id, vertex_ids):
        """
        Reads vector data into a provided block. This function reads values of specified vertices
        from a dataID. Values are read into a block of continuous memory.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_ids : array_like
            Indices of the vertices.

        Returns
        -------
        values : numpy.ndarray
            Contains the read data.

        Notes
        -----
        Previous calls:
            count of available elements at values matches the configured dimension * size
            count of available elements at vertex_ids matches the given size
            initialize() has been called

        Examples
        --------
        Read block vector data for a 2D problem with 5 vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = read_block_vector_data(data_id, vertex_ids)
        >>> values.shape
        >>> (5, 2)

        Read block vector data for a 3D system with 5 vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = read_block_vector_data(data_id, vertex_ids)
        >>> values.shape
        >>> (5, 3)
        """
        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        size = _vertex_ids.size
        dimensions = self.get_dimensions()
        cdef np.ndarray[np.double_t, ndim=1] _values = np.empty(size * dimensions, dtype=np.double)
        self.thisptr.readBlockVectorData (data_id, size, <const int*>_vertex_ids.data, <double*>_values.data)
        return _values.reshape((size, dimensions))

    def read_vector_data (self, data_id, vertex_id):
        """
        Reads vector data form a vertex. This function reads a value of a specified vertex
        from a dataID.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_id : int
            Index of the vertex.

        Returns
        -------
        value : numpy.array
            Contains the read data.

        Notes
        -----
        Previous calls:
            count of available elements at value matches the configured dimension
            initialize() has been called

        Examples
        --------
        Read vector data for 2D problem:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> value = interface.read_vector_data(data_id, vertex_id)
        >>> value.shape
        (1, 2)

        Read vector data for 2D problem:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> value = interface.read_vector_data(data_id, vertex_id)
        >>> value.shape
        (1, 3)
        """
        dimensions = self.get_dimensions()
        cdef np.ndarray[double, ndim=1] _value = np.empty(dimensions, dtype=np.double)
        self.thisptr.readVectorData (data_id, vertex_id, <double*>_value.data)
        return _value

    def read_block_scalar_data (self, data_id, vertex_ids):
        """
        Reads scalar data as a block. This function reads values of specified vertices from a dataID.
        Values are provided as a block of continuous memory.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_ids : array_like
            Indices of the vertices.

        Returns
        -------
            values : numpy.array
                Contains the read data.

        Notes
        -----
        Previous calls:
            count of available elements at values matches the given size
            count of available elements at vertex_ids matches the given size
            initialize() has been called

        Examples
        --------
        Read block scalar data for 2D and 3D problems with 5 vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = interface.read_block_scalar_data(data_id, vertex_ids)
        >>> values.size
        >>> 5

        """
        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        size = _vertex_ids.size
        cdef np.ndarray[double, ndim=1] _values = np.empty(size, dtype=np.double)
        self.thisptr.readBlockScalarData (data_id, size, <const int*>_vertex_ids.data, <double*>_values.data)
        return _values

    def read_scalar_data (self, data_id, vertex_id):
        """
        Reads scalar data of a vertex. This function needs a value of a specified vertex from a dataID.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_id : int
            Index of the vertex.

        Returns
        -------
        value : double
            Contains the read value

        Notes
        -----
        Previous calls:
            initialize() has been called.

        Examples
        --------
        Read scalar data for 2D and 3D problems:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> value = interface.read_scalar_data(data_id, vertex_id)
        """
        cdef double _value
        self.thisptr.readScalarData (data_id, vertex_id, _value)
        return _value

def get_version_information ():
    """
    Returns
    -------
    Current preCICE version information
    """
    return SolverInterface.getVersionInformation()

def action_write_initial_data ():
    """
    Returns
    -------
    Name of action for writing initial data
    """
    return SolverInterface.actionWriteInitialData()

def action_write_iteration_checkpoint ():
    """
    Returns
    -------
    Name of action for writing iteration checkpoint
    """
    return SolverInterface.actionWriteIterationCheckpoint()

def action_read_iteration_checkpoint ():
    """
    Returns
    -------
    Name of action for reading iteration checkpoint
    """
    return SolverInterface.actionReadIterationCheckpoint()
