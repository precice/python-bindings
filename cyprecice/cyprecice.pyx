# distutils: language = c++

"""precice

The python module precice offers python language bindings to the C++ coupling library precice. Please refer to precice.org for further information.
"""

cimport cyprecice
cimport numpy
import numpy as np
from mpi4py import MPI
import warnings
from libcpp.string cimport string
from libcpp.vector cimport vector

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

cdef class Participant:
    """
    Main Application Programming Interface of preCICE.
    To adapt a solver to preCICE, follow the following main structure:
        - Create an object of Participant with Participant()
        - Initialize preCICE with Participant::initialize()
        - Advance to the next (time)step with Participant::advance()
        - Finalize preCICE with Participant::finalize()
        - We use solver, simulation code, and participant as synonyms.
        - The preferred name in the documentation is participant.
    """

    # fake __init__ needed to display docstring for __cinit__ (see https://stackoverflow.com/a/42733794/5158031)
    def __init__(self, solver_name, configuration_file_name, solver_process_index, solver_process_size, communicator=None):
        """
        Constructor of Participant class.

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
        Participant : object
            Object pointing to the defined participant

        Example
        -------
        >>> participant = precice.Participant("SolverOne", "precice-config.xml", 0, 1)
        preCICE: This is preCICE version X.X.X
        preCICE: Revision info: vX.X.X-X-XXXXXXXXX
        preCICE: Configuring preCICE with configuration: "precice-config.xml"

        """
        pass

    def __cinit__ (self, solver_name, configuration_file_name, solver_process_index, solver_process_size, communicator=None):
        cdef void* communicator_ptr
        if communicator:
            communicator_ptr = <void*> communicator
            self.thisptr = new CppParticipant.Participant (convert(solver_name), convert(configuration_file_name), solver_process_index, solver_process_size, communicator_ptr)
        else:
            self.thisptr = new CppParticipant.Participant (convert(solver_name), convert(configuration_file_name), solver_process_index, solver_process_size)
        pass

    def __dealloc__ (self):
        """
        Destructor of Participant class
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
        self.thisptr.initialize ()


    def advance (self, double computed_timestep_length):
        """
        Advances preCICE after the solver has computed one timestep.

        Parameters
        ----------
        computed_timestep_length : double
            Length of timestep used by the solver.

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
        self.thisptr.advance (computed_timestep_length)


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

    def get_mesh_dimensions (self, mesh_name):
        """
        Returns the spatial dimensionality of the given mesh.

        Parameters
        ----------
        mesh_name : string
            Name of the mesh.

        Returns
        -------
        dimension : int
            The dimensions of the given mesh.
        """

        return self.thisptr.getMeshDimensions (convert(mesh_name))


    def get_data_dimensions (self, mesh_name, data_name):
        """
        Returns the spatial dimensionality of the given data on the given mesh.

        Parameters
        ----------
        mesh_name : string
            Name of the mesh.
        data_name : string
            Name of the data.

        Returns
        -------
        dimension : int
            The dimensions of the given data.
        """

        return self.thisptr.getDataDimensions (convert(mesh_name), convert(data_name))


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


    def get_max_time_step_size (self):
        """
        Get the maximum allowed time step size of the current window.

        Allows the user to query the maximum allowed time step size in the current window.
        This should be used to compute the actual time step that the solver uses.

        Returns
        -------
            tag : double
                Maximum size of time step to be computed by solver.

        Notes
        -----
        Previous calls:
            initialize() has been called successfully.
        """
        return self.thisptr.getMaxTimeStepSize ()


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

    # mesh access

    def requires_mesh_connectivity_for (self, mesh_name):
        """
        Checks if the given mesh requires connectivity.

        Parameters
        ----------
        mesh_name : string
            Name of the mesh.

        Returns
        -------
        tag : bool
            True if mesh connectivity is required.
        """
        return self.thisptr.requiresMeshConnectivityFor(convert(mesh_name))


    def set_mesh_vertex(self, mesh_name, position):
        """
        Creates a mesh vertex

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the vertex to.
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
            assert dimensions == self.get_mesh_dimensions(mesh_name), "Dimensions of vertex coordinate in set_mesh_vertex does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_mesh_dimensions(mesh_name))
        elif len(position) == 0:
            dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[double] cpp_position = position

        vertex_id = self.thisptr.setMeshVertex(convert(mesh_name), cpp_position)

        return vertex_id


    def get_mesh_vertex_size (self, mesh_name):
        """
        Returns the number of vertices of a mesh

        Parameters
        ----------
        mesh_name : str
            Name of the mesh.

        Returns
        -------
        sum : int
            Number of vertices of the mesh.
        """

        return self.thisptr.getMeshVertexSize(convert(mesh_name))


    def set_mesh_vertices (self, mesh_name, positions):
        """
        Creates multiple mesh vertices

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the vertices to.
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

        >>> positions = np.array([[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]])
        >>> positions.shape
        (5, 2)
        >>> mesh_name = "MeshOne"
        >>> vertex_ids = participant.set_mesh_vertices(mesh_name, positions)
        >>> vertex_ids.shape
        (5,)

        Set mesh vertices for a 3D problem with 5 mesh vertices.

        >>> positions = np.array([[1, 1, 1], [2, 2, 2], [3, 3, 3], [4, 4, 4], [5, 5, 5]])
        >>> positions.shape
        (5, 3)
        >>> mesh_name = "MeshOne"
        >>> vertex_ids = participant.set_mesh_vertices(mesh_name, positions)
        >>> vertex_ids.shape
        (5,)
        """
        check_array_like(positions, "positions", "set_mesh_vertices")

        if not isinstance(positions, np.ndarray):
            positions = np.asarray(positions)

        if len(positions) > 0:
            size, dimensions = positions.shape
            assert dimensions == self.get_mesh_dimensions(mesh_name), "Dimensions of vertex coordinates in set_mesh_vertices does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_mesh_dimensions(mesh_name))
        elif len(positions) == 0:
            size = 0
            dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[double] cpp_positions = positions.flatten()
        cdef vector[int] cpp_ids = [-1 for _ in range(size)]

        self.thisptr.setMeshVertices (convert(mesh_name), cpp_positions, cpp_ids)

        cdef np.ndarray[int, ndim=1] np_ids = np.array(cpp_ids, dtype=np.int32)

        return np_ids


    def set_mesh_edge (self, mesh_name, first_vertex_id, second_vertex_id):
        """
        Sets mesh edge from vertex IDs, returns edge ID.

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the edge to.
        first_vertex_id : int
            ID of the first vertex of the edge.
        second_vertex_id : int
            ID of the second vertex of the edge.

        Returns
        -------
        edge_id : int
            ID of the edge.

        Notes
        -----
        Previous calls:
            vertices with firstVertexID and secondVertexID were added to the mesh with name mesh_name
        """

        self.thisptr.setMeshEdge (convert(mesh_name), first_vertex_id, second_vertex_id)


    def set_mesh_edges (self, mesh_name, vertices):
        """
        Creates multiple mesh edges

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the vertices to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 2] where
            N = number of edges and D = dimensions of geometry.

        Examples
        --------
        Set mesh edges for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.

        >>> vertices = np.array([[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]])
        >>> vertices.shape
        (6, 2)
        >>> participant.set_mesh_edges(mesh_name, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_edges")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            _, n = vertices.shape
            assert n == 2, "Provided vertices are not of a [N x 2] format, but instead of a [N x {}]".format(n)
        elif len(vertices) == 0:
            dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[int] cpp_vertices = vertices.flatten()

        self.thisptr.setMeshEdges (convert(mesh_name), cpp_vertices)


    def set_mesh_triangle (self, mesh_name, first_vertex_id, second_vertex_id, third_vertex_id):
        """
        Set a mesh triangle from edge IDs

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the triangle to.
        first_vertex_id : int
            ID of the first vertex of the triangle.
        second_vertex_id : int
            ID of the second vertex of the triangle.
        third_vertex_id : int
            ID of the third vertex of the triangle.

        Notes
        -----
        Previous calls:
            vertices with first_vertex_id, second_vertex_id, and third_vertex_id were added to the mesh with the name mesh_name
        """

        self.thisptr.setMeshTriangle (convert(mesh_name), first_vertex_id, second_vertex_id, third_vertex_id)


    def set_mesh_triangles (self, mesh_name, vertices):
        """
        Creates multiple mesh triangles

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the triangles to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 3] where
            N = number of triangles and D = dimensions of geometry.

        Examples
        --------
        Set mesh triangles for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.

        >>> vertices = np.array([[1, 2, 3], [1, 3, 4], [1, 2, 4], [1, 3, 4]])
        >>> vertices.shape
        (4, 2)
        >>> participant.set_mesh_triangles(mesh_name, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_triangles")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            _, n = vertices.shape
            assert n == self.get_mesh_dimensions(mesh_name), "Provided vertices are not of a [N x {}] format, but instead of a [N x {}]".format(self.get_mesh_dimensions(mesh_name), n)
        elif len(vertices) == 0:
            dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[int] cpp_vertices = vertices.flatten()

        self.thisptr.setMeshTriangles (convert(mesh_name), cpp_vertices)


    def set_mesh_quad (self, mesh_name, first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id):
        """
        Set a mesh Quad from vertex IDs.

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the quad to.
        first_vertex_id : int
            ID of the first vertex of the quad.
        second_vertex_id : int
            ID of the second vertex of the quad.
        third_vertex_id : int
            ID of the third vertex of the quad.
        fourth_vertex_id : int
            ID of the third vertex of the quad.

        Notes
        -----
        Previous calls:
            vertices with first_vertex_id, second_vertex_id, third_vertex_id, and fourth_vertex_id were added
            to the mesh with the name mesh_name
        """

        self.thisptr.setMeshQuad (convert(mesh_name), first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id)


    def set_mesh_quads (self, mesh_name, vertices):
        """
        Creates multiple mesh quads

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the quads to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 4] where
            N = number of quads and D = dimensions of geometry.

        Examples
        --------
        Set mesh quads for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.

        >>> vertices = np.array([[1, 2, 3, 4]])
        >>> vertices.shape
        (1, 2)
        >>> participant.set_mesh_quads(mesh_name, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_quads")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            _, n = vertices.shape
            assert n == 4, "Provided vertices are not of a [N x 4] format, but instead of a [N x {}]".format(n)
        elif len(vertices) == 0:
            dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[int] cpp_vertices = vertices.flatten()

        self.thisptr.setMeshQuads (convert(mesh_name), cpp_vertices)


    def set_mesh_tetrahedron (self, mesh_name, first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id):
        """
        Sets a mesh tetrahedron from vertex IDs.

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the tetrahedron to.
        first_vertex_id : int
            ID of the first vertex of the tetrahedron.
        second_vertex_id : int
            ID of the second vertex of the tetrahedron.
        third_vertex_id : int
            ID of the third vertex of the tetrahedron.
        fourth_vertex_id : int
            ID of the third vertex of the tetrahedron.

        Notes
        -----
        Previous calls:
            vertices with first_vertex_id, second_vertex_id, third_vertex_id, and fourth_vertex_id were added
            to the mesh with the name mesh_name
        """

        self.thisptr.setMeshTetrahedron (convert(mesh_name), first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id)


    def set_mesh_tetrahedra (self, mesh_name, vertices):
        """
        Creates multiple mesh tetdrahedrons

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to add the tetrahedrons to.
        vertices : array_like
            The IDs of the vertices in a numpy array [N x 4] where
            N = number of quads and D = dimensions of geometry.

        Examples
        --------
        Set mesh tetrahedrons for a problem with 4 mesh vertices.

        >>> vertices = np.array([[1, 2, 3, 4]])
        >>> vertices.shape
        (1, 2)
        >>> participant.set_mesh_tetradehra(mesh_name, vertices)
        """
        check_array_like(vertices, "vertices", "set_mesh_tetrahedra")

        if not isinstance(vertices, np.ndarray):
            vertices = np.asarray(vertices)

        if len(vertices) > 0:
            _, n = vertices.shape
            assert n == 4, "Provided vertices are not of a [N x 4] format, but instead of a [N x {}]".format(n)
        elif len(vertices) == 0:
            dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[int] cpp_vertices = vertices.flatten()

        self.thisptr.setMeshTetrahedra (convert(mesh_name), cpp_vertices)

    # data access

    def write_data (self, mesh_name, data_name, vertex_ids, values):
        """
        This function writes values of specified vertices to data of a mesh.
        Values are provided as a block of continuous memory defined by values. Values are stored in a numpy array [N x D] where N = number of vertices and D = dimensions of geometry.
        The order of the provided data follows the order specified by vertices.

        Parameters
        ----------
        mesh_name : str
            name of the mesh to write to.
        data_name : str
            Data name to write to.
        vertex_ids : array_like
            Indices of the vertices.
        values : array_like
            Values of data

        Notes
        -----
        Previous calls:
            count of available elements at values matches the configured dimension * size
            count of available elements at vertex_ids matches the given size
            initialize() has been called

        Examples
        --------
        Write scalar data for a 2D problem with 5 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = np.array([v1, v2, v3, v4, v5])
        >>> participant.write_data(mesh_name, data_name, vertex_ids, values)

        Write vector data for a 2D problem with 5 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = np.array([[v1_x, v1_y], [v2_x, v2_y], [v3_x, v3_y], [v4_x, v4_y], [v5_x, v5_y]])
        >>> participant.write_data(mesh_name, data_name, vertex_ids, values)

        Write vector data for a 3D (D=3) problem with 5 (N=5) vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = np.array([[v1_x, v1_y, v1_z], [v2_x, v2_y, v2_z], [v3_x, v3_y, v3_z], [v4_x, v4_y, v4_z], [v5_x, v5_y, v5_z]])
        >>> participant.write_data(mesh_name, data_name, vertex_ids, values)
        """
        check_array_like(vertex_ids, "vertex_ids", "write_data")
        check_array_like(values, "values", "write_data")

        if not isinstance(values, np.ndarray):
            values = np.asarray(values)

        if len(values) == 0:
            size = 0
        elif self.get_data_dimensions(mesh_name, data_name) == 1:
            size = values.flatten().shape[0]
            dimensions = 1
        else:
            assert len(values.shape) == 2, "Vector valued data has to be provided as a numpy array of shape [N x D] where N = number of vertices and D = number of dimensions."
            size, dimensions = values.shape

            assert dimensions == self.get_data_dimensions(mesh_name, data_name), "Dimensions of vector data in write_data do not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_data_dimensions(mesh_name, data_name))

        assert len(vertex_ids) == size, "Vertex IDs are of incorrect length in write_data. Check length of vertex ids input. Provided size: {}, expected size: {}".format(vertex_ids.size, size)

        cdef vector[int] cpp_ids = vertex_ids
        cdef vector[double] cpp_values = values.flatten()

        self.thisptr.writeData (convert(mesh_name), convert(data_name), cpp_ids, cpp_values)


    def read_data (self, mesh_name, data_name, vertex_ids, relative_read_time):
        """
        Reads data into a provided block. This function reads values of specified vertices
        from a dataID. Values are read into a block of continuous memory.

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to write to.
        data_name : str
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
        Read scalar data for a 2D problem with 5 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = read_data(mesh_name, data_name, vertex_ids)
        >>> values.shape
        >>> (5, )

        Read vector data for a 2D problem with 5 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = read_data(mesh_name, data_name, vertex_ids)
        >>> values.shape
        >>> (5, 2)

        Read vector data for a 3D system with 5 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2, 3, 4, 5]
        >>> values = read_data(mesh_name, data_name, vertex_ids)
        >>> values.shape
        >>> (5, 3)
        """
        check_array_like(vertex_ids, "vertex_ids", "read_data")

        if len(vertex_ids) == 0:
            size = 0
            dimensions =  self.get_data_dimensions(mesh_name, data_name)
        elif self.get_data_dimensions(mesh_name, data_name) == 1:
            size = len(vertex_ids)
            dimensions = 1
        else:
            size = len(vertex_ids)
            dimensions =  self.get_data_dimensions(mesh_name, data_name)

        cdef vector[int] cpp_ids = vertex_ids
        cdef vector[double] cpp_values = [-1 for _ in range(size * dimensions)]

        self.thisptr.readData (convert(mesh_name), convert(data_name), cpp_ids, relative_read_time, cpp_values)

        cdef np.ndarray[double, ndim=1] np_values = np.array(cpp_values, dtype=np.double)

        if len(vertex_ids) == 0:
            return np_values.reshape((size))
        elif self.get_data_dimensions(mesh_name, data_name) == 1:
            return np_values.reshape((size))
        else:
            return np_values.reshape((size, dimensions))


    def write_gradient_data (self, mesh_name, data_name, vertex_ids, gradients):
        """
        Writes gradient data given as block. This function writes gradient values of specified vertices to a dataID.
        Values are provided as a block of continuous memory. Values are stored in a numpy array [N x D] where N = number
        of vertices and D = number of gradient components.

        Parameters
        ----------
        mesh_name : str
            Name of the mesh to write to.
        data_name : str
            Data name to write to.
        vertex_ids : array_like
            Indices of the vertices.
        gradients : array_like
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
        Write gradient vector data for a 2D problem with 2 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2]
        >>> gradients = np.array([[v1x_dx, v1y_dx, v1x_dy, v1y_dy], [v2x_dx, v2y_dx, v2x_dy, v2y_dy]])
        >>> participant.write_gradient_data(mesh_name, data_name, vertex_ids, gradients)

        Write vector data for a 3D problem with 2 vertices:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> vertex_ids = [1, 2]
        >>> gradients = np.array([[v1x_dx, v1y_dx, v1z_dx, v1x_dy, v1y_dy, v1z_dy, v1x_dz, v1y_dz, v1z_dz], [v2x_dx, v2y_dx, v2z_dx, v2x_dy, v2y_dy, v2z_dy, v2x_dz, v2y_dz, v2z_dz]])
        >>> participant.write_gradient_data(mesh_name, data_name, vertex_ids, gradients)
        """
        check_array_like(vertex_ids, "vertex_ids", "write_gradient_data")
        check_array_like(gradients, "gradients", "write_gradient_data")

        if not isinstance(gradients, np.ndarray):
            gradients = np.asarray(gradients)

        if len(gradients) > 0:
            size, dimensions = gradients.shape
            assert dimensions == self.get_mesh_dimensions(mesh_name) * self.get_data_dimensions(mesh_name, data_name), "Dimensions of vector data in write_gradient_data does not match with dimensions in problem definition. Provided dimensions: {}, expected dimensions: {}".format(dimensions, self.get_mesh_dimensions(mesh_name) *  self.get_data_dimensions (mesh_name, data_name))
        if len(gradients) == 0:
            size = 0

        cdef vector[int] cpp_vertex_ids = vertex_ids
        cdef vector[double] cpp_gradients = gradients.flatten()

        assert cpp_gradients.size() == size * self.get_mesh_dimensions(mesh_name) * self.get_data_dimensions (mesh_name, data_name), "Dimension of gradient data provided in write_gradient_data does not match problem definition. Check length of input data provided. Provided size: {}, expected size: {}".format(cpp_gradients.size(), size * self.get_mesh_dimensions(mesh_name) * self.get_data_dimensions (mesh_name, data_name))
        assert cpp_vertex_ids.size() == size, "Vertex IDs are of incorrect length in write_gradient_data. Check length of vertex ids input. Provided size: {}, expected size: {}".format(cpp_vertex_ids.size(), size)

        self.thisptr.writeGradientData (convert(mesh_name), convert(data_name), cpp_vertex_ids, cpp_gradients)


    def requires_gradient_data_for(self, mesh_name, data_name):
        """
        Checks if the given data set requires gradient data. We check if the data object has been intialized with the gradient flag.

        Parameters
        ----------
        mesh_name : str
            Mesh name to check.
        data_name : str
            Data name to check.

        Returns
        -------
        bool
            True if gradient data is required for a data.

        Examples
        --------
        Check if gradient data is required for a data:
        >>> mesh_name = "MeshOne"
        >>> data_name = "DataOne"
        >>> participant.is_gradient_data_required(mesh_name, data_name)
        """

        return self.thisptr.requiresGradientDataFor(convert(mesh_name), convert(data_name))


    def set_mesh_access_region (self, mesh_name, bounding_box):
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
        mesh_name : str
            Name of the mesh you want to access through the bounding box
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
        check_array_like(bounding_box, "bounding_box", "set_mesh_access_region")

        if not isinstance(bounding_box, np.ndarray):
            bounding_box = np.asarray(bounding_box)

        assert len(bounding_box) > 0, "Bounding box cannot be empty."

        assert len(bounding_box) == (self.get_mesh_dimensions(mesh_name) * 2), "Dimensions of bounding box in set_mesh_access_region does not match with dimensions in problem definition."

        cdef vector[double] cpp_bounding_box = list(bounding_box)

        self.thisptr.setMeshAccessRegion(convert(mesh_name), cpp_bounding_box)


    def get_mesh_vertex_ids_and_coordinates (self, mesh_name):
        """
        Iterating over the region of interest defined by bounding boxes and reading the corresponding
        coordinates omitting the mapping. This function is still experimental.

        Parameters
        ----------
        mesh_name : str
            Corresponding mesh name

        Returns
        -------
        ids : numpy.ndarray
            Vertex IDs corresponding to the coordinates
        coordinates : numpy.ndarray
            he coordinates associated to the IDs and corresponding data values (dim * size)
        """
        size = self.get_mesh_vertex_size(mesh_name)
        dimensions = self.get_mesh_dimensions(mesh_name)

        cdef vector[int] cpp_ids = [-1 for _ in range(size)]
        cdef vector[double] cpp_coordinates = [-1 for _ in range(size * dimensions)]

        self.thisptr.getMeshVertexIDsAndCoordinates(convert(mesh_name), cpp_ids, cpp_coordinates)

        cdef np.ndarray[int, ndim=1] np_ids = np.array(cpp_ids, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] np_coordinates = np.array(cpp_coordinates, dtype=np.double)

        return np_ids, np_coordinates.reshape((size, dimensions))

def get_version_information ():
    """
    Returns
    -------
    Current preCICE version information
    """
    return CppParticipant.getVersionInformation()
