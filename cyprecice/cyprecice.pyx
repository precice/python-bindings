# distutils: language = c++

"""precice

The python module precice offers python language bindings to the C++ coupling library precice. Please refer to precice.org for further information.
"""

cimport cyprecice
import numpy as np
from mpi4py import MPI
import warnings

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


def check_array_like(argument, argument_name, function_name):
    try:
        argument.__len__
        argument.__getitem__
    except AttributeError:
        raise TypeError("{} requires array_like input for {}, but was provided the following input type: {}".format(
            function_name, argument_name, type(argument))) from None

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
        communicator: mpi4py.MPI.Intracomm, optional
            Custom MPI communicator to use

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
        Fully initializes preCICE and initializes coupling data. The starting values for coupling data are zero by
        default. To provide custom values, first set the data using the Data Access methods before calling this
        method to finally exchange the data.

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

    def requires_initial_data (self):
        """
        Checks if the participant is required to provide initial data.
        If true, then the participant needs to write initial data to defined vertices
        prior to calling initialize().

        Returns
        -------
        tag : bool
            Returns True if inital data is required.

        Notes
        -----
        Previous calls:
            initialize() has not yet been called
        """
        return self.thisptr.requiresInitialData ()

    def requires_reading_checkpoint (self):
        """
        Checks if the participant is required to read an iteration checkpoint.
        
        If true, the participant is required to read an iteration checkpoint before
        calling advance().

        preCICE refuses to proceed if reading a checkpoint is required,
        but this method isn't called prior to advance().

        Notes
        -----
        This function returns false before the first call to advance().

        Previous calls:
            initialize() has been called
        """
        return self.thisptr.requiresReadingCheckpoint ()

    def requires_writing_checkpoint (self):
        """
        Checks if the participant is required to write an iteration checkpoint.
        
        If true, the participant is required to write an iteration checkpoint before
        calling advance().
        
        preCICE refuses to proceed if writing a checkpoint is required,
        but this method isn't called prior to advance().

        Notes
        -----
        Previous calls:
            initialize() has been called
        """
        return self.thisptr.requiresWritingCheckpoint ()

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
        check_array_like(position, "position", "set_mesh_vertex")

        if len(position) > 0:
            dimensions = len(position)
            assert dimensions == self.get_dimensions(), "Dimensions of vertex coordinate in set_mesh_vertex does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_dimensions())
        elif len(position) == 0:
            dimensions = self.get_dimensions()

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
        vertex_ids : numpy.ndarray
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
        check_array_like(positions, "positions", "set_mesh_vertices")

        if not isinstance(positions, np.ndarray):
            positions = np.asarray(positions)

        if len(positions) > 0:
            size, dimensions = positions.shape
            assert dimensions == self.get_dimensions(), "Dimensions of vertex coordinates in set_mesh_vertices does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_dimensions())
        elif len(positions) == 0:
            size = positions.shape[0]
            dimensions = self.get_dimensions()

        cdef np.ndarray[double, ndim=1] _positions = np.ascontiguousarray(positions.flatten(), dtype=np.double)
        cdef np.ndarray[int, ndim=1] vertex_ids = np.empty(size, dtype=np.int32)
        self.thisptr.setMeshVertices (mesh_id, size, <const double*>_positions.data, <int*>vertex_ids.data)
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
        self.thisptr.setMeshEdge (mesh_id, first_vertex_id, second_vertex_id)

    def set_mesh_edges (self, mesh_id, vertices):
        """
        Creates multiple mesh edges

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the vertices to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 2] where
            N = number of edges and D = dimensions of geometry.

        Examples
        --------
        Set mesh edges for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> vertices = np.array([[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]])
        >>> vertices.shape
        (6, 2)
        >>> interface.set_mesh_edges(mesh_id, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_edges")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            size, n = vertices.shape
            assert n == 2, "Provided vertices are not of a [N x 2] format, but instead of a [N x {}]".format(n)
        elif len(vertices) == 0:
            size = vertices.shape[0]
            dimensions = self.get_dimensions()

        cdef np.ndarray[double, ndim=1] _vertices = np.ascontiguousarray(vertices.flatten(), dtype=np.int)
        self.thisptr.setMeshEdges (mesh_id, size, <const int*>_vertices.data)

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

    def set_mesh_triangles (self, mesh_id, vertices):
        """
        Creates multiple mesh triangles

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the vertices to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 3] where
            N = number of triangles and D = dimensions of geometry.

        Examples
        --------
        Set mesh triangles for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> vertices = np.array([[1, 2, 3], [1, 3, 4], [1, 2, 4], [1, 3, 4]])
        >>> vertices.shape
        (4, 2)
        >>> interface.set_mesh_triangles(mesh_id, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_triangles")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            size, n = vertices.shape
            assert n == 3, "Provided vertices are not of a [N x 3] format, but instead of a [N x {}]".format(n)
        elif len(vertices) == 0:
            size = vertices.shape[0]
            dimensions = self.get_dimensions()

        cdef np.ndarray[double, ndim=1] _vertices = np.ascontiguousarray(vertices.flatten(), dtype=np.int)
        self.thisptr.setMeshTriangles (mesh_id, size, <const int*>_vertices.data)

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

    def set_mesh_quads (self, mesh_id, vertices):
        """
        Creates multiple mesh quads

        Parameters
        ----------
        mesh_id : int
            ID of the mesh to add the vertices to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 4] where
            N = number of quads and D = dimensions of geometry.

        Examples
        --------
        Set mesh quads for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.

        >>> mesh_id = interface.get_mesh_id("MeshOne")
        >>> vertices = np.array([[1, 2, 3, 4]])
        >>> vertices.shape
        (1, 2)
        >>> interface.set_mesh_quads(mesh_id, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_quads")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            size, n = vertices.shape
            assert n == 4, "Provided vertices are not of a [N x 4] format, but instead of a [N x {}]".format(n)
        elif len(vertices) == 0:
            size = vertices.shape[0]
            dimensions = self.get_dimensions()

        cdef np.ndarray[double, ndim=1] _vertices = np.ascontiguousarray(vertices.flatten(), dtype=np.int)
        self.thisptr.setMeshQuads (mesh_id, size, <const int*>_vertices.data)

    # data access

    def requires_mesh_connectivity_for (self, mesh_id):
        """
        Checks if the given mesh requires connectivity.

        Parameters
        ----------
        mesh_id : int
            ID of the associated mesh.

        Returns
        -------
        tag : bool
            True if mesh connectivity is required.
        """
        return self.thisptr.requiresMeshConnectivityFor(mesh_id)

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
        values : array_like
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
        check_array_like(vertex_ids, "vertex_ids", "write_block_vector_data")
        check_array_like(values, "values", "write_block_vector_data")

        if not isinstance(values, np.ndarray):
            values = np.asarray(values)

        if len(values) > 0:
            size, dimensions = values.shape
            assert dimensions == self.get_dimensions(), "Dimensions of vector data in write_block_vector_data does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_dimensions())
        if len(values) == 0:
            size = 0

        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _values = np.ascontiguousarray(values.flatten(), dtype=np.double)

        assert _values.size == size * self.get_dimensions(), "Vector data is not provided for all vertices in write_block_vector_data. Check length of input data provided. Provided size: {}, expected size: {}".format(_values.size, size * self.get_dimensions())
        assert _vertex_ids.size == size, "Vertex IDs are of incorrect length in write_block_vector_data. Check length of vertex ids input. Provided size: {}, expected size: {}".format(_vertex_ids.size, size)

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
        value : array_like
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
        check_array_like(value, "value", "write_vector_data")
        assert len(value) > 0, "Input vector data is empty in write_vector_data"

        dimensions = len(value)

        assert dimensions == self.get_dimensions(), "Dimensions of vector data in write_vector_data does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_dimensions())

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
        values : array_like
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
        >>> values = np.array([v1, v2, v3, v4, v5])
        >>> interface.write_block_scalar_data(data_id, vertex_ids, values)
        """
        check_array_like(vertex_ids, "vertex_ids", "write_block_scalar_data")
        check_array_like(values, "values", "write_block_scalar_data")

        if len(values) > 0:
            assert(len(vertex_ids) == len(values))
            size = len(vertex_ids)
        if len(values) == 0:
            size = 0

        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _values = np.ascontiguousarray(values, dtype=np.double)

        assert _values.size == size, "Scalar data is not provided for all vertices in write_block_scalar_data. Check size of input data provided. Provided size: {}, expected size: {}".format(_values.size, size)
        assert _vertex_ids.size == size, "Vertex IDs are of incorrect length in write_block_scalar_data. Check size of vertex ids input. Provided size: {}, expected size: {}".format(_vertex_ids.size, size)
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

    def read_block_vector_data (self, data_id, vertex_ids, relative_read_time=None):
        """
        Reads vector data into a provided block. This function reads values of specified vertices
        from a dataID. Values are read into a block of continuous memory.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_ids : array_like
            Indices of the vertices.
        relative_read_time : double
            Point in time where data is read relative to the beginning of the current time step

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
        check_array_like(vertex_ids, "vertex_ids", "read_block_vector_data")

        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        size = _vertex_ids.size
        dimensions = self.get_dimensions()
        cdef np.ndarray[np.double_t, ndim=1] _values = np.empty(size * dimensions, dtype=np.double)
        if relative_read_time is None:
            self.thisptr.readBlockVectorData (data_id, size, <const int*>_vertex_ids.data, <double*>_values.data)
        else:
            self.thisptr.readBlockVectorData (data_id, size, <const int*>_vertex_ids.data, relative_read_time, <double*>_values.data)
        return _values.reshape((size, dimensions))

    def read_vector_data (self, data_id, vertex_id, relative_read_time=None):
        """
        Reads vector data form a vertex. This function reads a value of a specified vertex
        from a dataID.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_id : int
            Index of the vertex.
        relative_read_time : double
            Point in time where data is read relative to the beginning of the current time step

        Returns
        -------
        value : numpy.ndarray
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
        if relative_read_time == None:
            self.thisptr.readVectorData (data_id, vertex_id, <double*>_value.data)
        else:
            self.thisptr.readVectorData (data_id, vertex_id, relative_read_time, <double*>_value.data)

        return _value

    def read_block_scalar_data (self, data_id, vertex_ids, relative_read_time=None):
        """
        Reads scalar data as a block. This function reads values of specified vertices from a dataID.
        Values are provided as a block of continuous memory.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_ids : array_like
            Indices of the vertices.
        relative_read_time : double
            Point in time where data is read relative to the beginning of the current time step

        Returns
        -------
            values : numpy.ndarray
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
        check_array_like(vertex_ids, "vertex_ids", "read_block_scalar_data")

        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        size = _vertex_ids.size
        cdef np.ndarray[double, ndim=1] _values = np.empty(size, dtype=np.double)
        if relative_read_time == None:
            self.thisptr.readBlockScalarData (data_id, size, <const int*>_vertex_ids.data, <double*>_values.data)
        else:
            self.thisptr.readBlockScalarData (data_id, size, <const int*>_vertex_ids.data, relative_read_time, <double*>_values.data)

        return _values

    def read_scalar_data (self, data_id, vertex_id, relative_read_time=None):
        """
        Reads scalar data of a vertex. This function needs a value of a specified vertex from a dataID.

        Parameters
        ----------
        data_id : int
            ID to read from.
        vertex_id : int
            Index of the vertex.
        relative_read_time : double
            Point in time where data is read relative to the beginning of the current time step

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
        if relative_read_time == None:
            self.thisptr.readScalarData (data_id, vertex_id, _value)
        else:
            self.thisptr.readScalarData (data_id, vertex_id, relative_read_time, _value)

        return _value

    def write_block_vector_gradient_data (self, data_id, vertex_ids, gradientValues):
        """
        Writes vector gradient data given as block. This function writes gradient values of specified vertices to a dataID.
        Values are provided as a block of continuous memory. Values are stored in a numpy array [N x D] where N = number
        of vertices and D = number of gradient components.

        Parameters
        ----------
        data_id : int
            Data ID to write to.
        vertex_ids : array_like
            Indices of the vertices.
        gradientValues : array_like
             Gradient values differentiated in the spacial direction (dx, dy) for 2D space, (dx, dy, dz) for 3D space

        Notes
        -----
        Previous calls:
            Count of available elements at values matches the configured dimension
            Count of available elements at vertex_ids matches the given size
            Initialize() has been called
            Data with dataID has attribute hasGradient = true

        Examples
        --------
        Write block gradient vector data for a 2D problem with 2 vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2]
        >>> gradientValues = np.array([[v1x_dx, v1y_dx, v1x_dy, v1y_dy], [v2x_dx, v2y_dx, v2x_dy, v2y_dy]])
        >>> interface.write_block_vector_gradient_data(data_id, vertex_ids, gradientValues)

        Write block vector data for a 3D (D=3) problem with 2 (N=2) vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2]
        >>> gradientValues = np.array([[v1x_dx, v1y_dx, v1z_dx, v1x_dy, v1y_dy, v1z_dy, v1x_dz, v1y_dz, v1z_dz], [v2x_dx, v2y_dx, v2z_dx, v2x_dy, v2y_dy, v2z_dy, v2x_dz, v2y_dz, v2z_dz]])
        >>> interface.write_block_vector_gradient_data(data_id, vertex_ids, gradientValues)
        """
        check_array_like(vertex_ids, "vertex_ids", "write_block_vector_gradient_data")
        check_array_like(gradientValues, "gradientValues", "write_block_vector_gradient_data")

        if not isinstance(gradientValues, np.ndarray):
            gradientValues = np.asarray(gradientValues)

        if len(gradientValues) > 0:
            size, dimensions = gradientValues.shape
            assert dimensions == self.get_dimensions() * self.get_dimensions(), "Dimensions of vector data in write_block_vector_gradient_data does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_dimensions() *  self.get_dimensions())
        if len(gradientValues) == 0:
            size = 0

        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _gradientValues = np.ascontiguousarray(gradientValues.flatten(), dtype=np.double)

        assert _gradientValues.size == size * self.get_dimensions() * self.get_dimensions(), "Dimension of vector gradient data provided in write_block_vector_gradient_data does not match problem definition. Check length of input data provided. Provided size: {}, expected size: {}".format(_gradientValues.size, size * self.get_dimensions() * self.get_dimensions())
        assert _vertex_ids.size == size, "Vertex IDs are of incorrect length in write_block_vector_gradient_data. Check length of vertex ids input. Provided size: {}, expected size: {}".format(_vertex_ids.size, size)

        self.thisptr.writeBlockVectorGradientData (data_id, size, <const int*>_vertex_ids.data, <const double*>_gradientValues.data)

    def write_scalar_gradient_data (self, data_id, vertex_id, gradientValues):
        """
        Writes scalar gradient data to a vertex
        This function writes the corresponding gradient matrix value of a specified vertex to a dataID.

        The gradients need to be provided in the following format:

        The 2D-format of gradientValues is (v_dx, v_dy) vector corresponding to the data block v = (v)
        differentiated respectively in x-direction dx and y-direction dy

        The 3D-format of gradientValues is (v_dx, v_dy, v_dz) vector
        corresponding to the data block v = (v) differentiated respectively in spatial directions x-direction dx and y-direction dy and z-direction dz

        Parameters
        ----------
        data_id : int
            ID to write to.
        vertex_id : int
            Index of the vertex.
        gradientValue : array_like
            A vector of the gradient values.

        Notes
        -----
        Count of available elements at value matches the configured dimension
        Vertex with dataID exists and contains data
        Data with dataID has attribute hasGradient = true

        Previous calls:
            initialize() has been called

        Examples
        --------
        Write scalar data for a 2D problem:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> gradientValue = [v5_dx, v5_dy]
        >>> interface.write_scalar_gradient_data(data_id, vertex_id, gradientValue)
        """

        check_array_like(gradientValues, "gradientValues", "write_scalar_gradient_data")

        if not isinstance(gradientValues, np.ndarray):
            gradientValues = np.asarray(gradientValues)

        cdef np.ndarray[double, ndim=1] _gradientValues = np.ascontiguousarray(gradientValues.flatten(), dtype=np.double)

        assert _gradientValues.size == self.get_dimensions(), "Vector data provided for vertex {} in write_scalar_gradient_data does not match problem definition. Check length of input data provided. Provided size: {}, expected size: {}".format(_gradientValues.size, self.get_dimensions())

        self.thisptr.writeScalarGradientData(data_id, vertex_id, <const double*>_gradientValues.data)

    def write_vector_gradient_data (self, data_id, vertex_id, gradientValues):
        """
        Writes vector gradient data to a vertex
        This function writes the corresponding gradient matrix value of a specified vertex to a dataID.

        The gradients need to be provided in the following format:

        The 2D-format of \p gradientValues is (vx_dx, vy_dx, vx_dy, vy_dy) vector corresponding to the data block v = (vx, vy)
        differentiated respectively in x-direction dx and y-direction dy

        The 3D-format of \p gradientValues is (vx_dx, vy_dx, vz_dx, vx_dy, vy_dy, vz_dy, vx_dz, vy_dz, vz_dz) vector
        corresponding to the data block v = (vx, vy, vz) differentiated respectively in spatial directions x-direction dx and y-direction dy and z-direction dz

        Parameters
        ----------
        data_id : int
            ID to write to.
        vertex_id : int
            Index of the vertex.
        gradientValue : array_like
            A vector of the gradient values.

        Notes
        -----
        Count of available elements at value matches the configured dimension
        Vertex with dataID exists and contains data
        Data with dataID has attribute hasGradient = true

        Previous calls:
            initialize() has been called

        Examples
        --------
        Write scalar data for a 2D problem:
        >>> data_id = 1
        >>> vertex_id = 5
        >>> gradientValue = [v5x_dx, v5y_dx, v5x_dy,v5y_dy]
        >>> interface.write_vector_gradient_data(data_id, vertex_id, gradientValue)
        """

        check_array_like(gradientValues, "gradientValues", "write_vector_gradient_data")

        if not isinstance(gradientValues, np.ndarray):
            gradientValues = np.asarray(gradientValues)

        cdef np.ndarray[double, ndim=1] _gradientValues = np.ascontiguousarray(gradientValues.flatten(), dtype=np.double)

        assert _gradientValues.size == self.get_dimensions() * self.get_dimensions(), "Dimensions of vector gradient data provided for vertex {} in write_vector_gradient_data does not match problem definition. Check length of input data provided. Provided size: {}, expected size: {}".format(_gradientValues.size, self.get_dimensions() * self.get_dimensions())

        self.thisptr.writeVectorGradientData(data_id, vertex_id, <const double*>_gradientValues.data)

    def write_block_scalar_gradient_data (self, data_id, vertex_ids, gradientValues):
        """
        Writes scalar gradient data given as block. This function writes values of specified vertices to a dataID.
        Values are provided as a block of continuous memory. Values are stored in a numpy array [N x D] where N = number
        of vertices and D = dimensions of geometry.

        Parameters
        ----------
        data_id : int
            Data ID to write to.
        vertex_ids : array_like
            Indices of the vertices.
        gradientValues : array_like
             Gradient values differentiated in the spacial direction (dx, dy) for 2D space, (dx, dy, dz) for 3D space

        Notes
        -----
        Previous calls:
            Count of available elements at values matches the configured dimension
            Count of available elements at vertex_ids matches the given size
            Initialize() has been called
            Data with dataID has attribute hasGradient = true

        Examples
        --------
        Write block gradient scalar data for a 2D problem with 2 vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2]
        >>> gradientValues = np.array([[v1_dx, v1_dy], [v2_dx, v2_dy]])
        >>> interface.write_block_scalar_gradient_data(data_id, vertex_ids, gradientValues)

        Write block scalar data for a 3D (D=3) problem with 2 (N=2) vertices:
        >>> data_id = 1
        >>> vertex_ids = [1, 2]
        >>> values = np.array([[v1_dx, v1_dy, v1x_dz], [v2_dx, v2_dy, v2_dz]])
        >>> interface.write_block_scalar_gradient_data(data_id, vertex_ids, values)
        """
        check_array_like(vertex_ids, "vertex_ids", "write_block_scalar_gradient_data")
        check_array_like(gradientValues, "gradientValues", "write_block_sclar_gradient_data")

        if not isinstance(gradientValues, np.ndarray):
            gradientValues = np.asarray(gradientValues)

        if len(gradientValues) > 0:
            size, dimensions = gradientValues.shape
            assert dimensions == self.get_dimensions() , "Dimensions of scalar gradient data  provided in write_block_scalar_gradient_data does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_dimensions())
        if len(gradientValues) == 0:
            size = 0

        cdef np.ndarray[int, ndim=1] _vertex_ids = np.ascontiguousarray(vertex_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _gradientValues = np.ascontiguousarray(gradientValues.flatten(), dtype=np.double)

        assert _gradientValues.size == size * self.get_dimensions(), "Scalar gradient data is not provided for all vertices in write_block_scalar_gradient_data. Check length of input data provided. Provided size: {}, expected size: {}".format(_gradientValues.size, size * self.get_dimensions())
        assert _vertex_ids.size == size, "Vertex IDs are of incorrect length in write_block_scalar_gradient_data. Check length of vertex ids input. Provided size: {}, expected size: {}".format(_vertex_ids.size, size)

        self.thisptr.writeBlockScalarGradientData (data_id, size, <const int*>_vertex_ids.data, <const double*>_gradientValues.data)

    def requires_gradient_data_for(self, data_id):
        """
        Checks if the given data set requires gradient data. We check if the data object has been intialized with the gradient flag.

        Parameters
        ----------
        data_id : int
            Data ID to check.

        Returns
        -------
        bool
            True if gradient data is required for a dataID.

        Examples
        --------
        Check if gradient data is required for a dataID:
        >>> data_id = 1
        >>> interface.is_gradient_data_required(data_id)
        """
        return self.thisptr.requiresGradientDataFor(data_id)

    def set_mesh_access_region (self, mesh_id, bounding_box):
        """
        This function is required if you don't want to use the mapping schemes in preCICE, but rather
        want to use your own solver for data mapping. As opposed to the usual preCICE mapping, only a
        single mesh (from the other participant) is now involved in this situation since an 'own'
        mesh defined by the participant itself is not required any more. In order to re-partition the
        received mesh, the participant needs to define the mesh region it wants read data from and
        write data to. The mesh region is specified through an axis-aligned bounding box given by the
        lower and upper [min and max] bounding-box limits in each space dimension [x, y, z]. This function is still
        experimental

        Parameters
        ----------
        mesh_id : int
            ID of the mesh you want to access through the bounding box
        bounding_box : array_like
            Axis aligned bounding box. Example for 3D the format: [x_min, x_max, y_min, y_max, z_min, z_max]

        Notes
        -----
        Defining a bounding box for serial runs of the solver (not to be confused with serial coupling
        mode) is valid. However, a warning is raised in case vertices are filtered out completely
        on the receiving side, since the associated data values of the filtered vertices are filled
        with zero data.

        This function can only be called once per participant and rank and trying to call it more than
        once results in an error.

        If you combine the direct access with a mapping (say you want to read data from a defined
        mesh, as usual, but you want to directly access and write data on a received mesh without a
        mapping) you may not need this function at all since the region of interest is already defined
        through the defined mesh used for data reading. This is the case if you define any mapping
        involving the directly accessed mesh on the receiving participant. (In parallel, only the cases
        read-consistent and write-conservative are relevant, as usual).

        The safety factor scaling (see safety-factor in the configuration file) is not applied to the
        defined access region and a specified safety will be ignored in case there is no additional
        mapping involved. However, in case a mapping is in addition to the direct access involved, you
        will receive (and gain access to) vertices inside the defined access region plus vertices inside
        the safety factor region resulting from the mapping. The default value of the safety factor is
        0.5, i.e. the defined access region as computed through the involved provided mesh is by 50%
        enlarged.
        """
        warnings.warn("The function set_mesh_access_region is still experimental.")

        check_array_like(bounding_box, "bounding_box", "set_mesh_access_region")

        if not isinstance(bounding_box, np.ndarray):
            bounding_box = np.asarray(bounding_box)

        assert len(bounding_box) > 0, "Bounding box cannot be empty."

        assert len(bounding_box) == (self.get_dimensions() * 2), "Dimensions of bounding box in set_mesh_access_region does not match with dimensions in problem definition."

        cdef np.ndarray[double, ndim=1] _bounding_box = np.ascontiguousarray(bounding_box, dtype=np.double)

        self.thisptr.setMeshAccessRegion(mesh_id, <double*>_bounding_box.data)

    def get_mesh_vertices_and_ids (self, mesh_id):
        """
        Iterating over the region of interest defined by bounding boxes and reading the corresponding
        coordinates omitting the mapping. This function is still experimental.

        Parameters
        ----------
        mesh_id : int
            Corresponding mesh ID

        Returns
        -------
        ids : numpy.ndarray
            Vertex IDs correspdoning to the coordinates
        coordinates : numpy.ndarray
            he coordinates associated to the IDs and corresponding data values (dim * size)
        """
        warnings.warn("The function get_mesh_vertices_and_ids is still experimental.")

        size = self.get_mesh_vertex_size(mesh_id)
        cdef np.ndarray[int, ndim=1] _ids = np.empty(size, dtype=np.int32)
        dimensions = self.get_dimensions()
        cdef np.ndarray[double, ndim=1] _coordinates = np.empty(size*dimensions, dtype=np.double)

        self.thisptr.getMeshVerticesAndIDs(mesh_id, size, <int*>_ids.data, <double*>_coordinates.data)

        return _ids, _coordinates.reshape((size, dimensions))

def get_version_information ():
    """
    Returns
    -------
    Current preCICE version information
    """
    return SolverInterface.getVersionInformation()
