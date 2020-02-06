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

## @package docstring
#  @brief Main Application Programming Interface of preCICE
#
#  To adapt a solver to preCICE, follow the following main structure:
#
#  -# Create an object of SolverInterface with Interface()
#  -# Configure the object with Interface::configure()
#  -# Initialize preCICE with Interface::initialize()
#  -# Advance to the next (time)step with Interface::advance()
#  -# Finalize preCICE with Interface::finalize()
#
#  @note
#  We use solver, simulation code, and participant as synonyms.
#  The preferred name in the documentation is participant.
#
cdef class Interface:
    # construction and configuration
    # constructor

    def __cinit__ (self, solver_name, configuration_file_name, solver_process_index, solver_process_size, communicator=None):
        cdef void* communicator_ptr
        if communicator:
            communicator_ptr = <void*> communicator
            self.thisptr = new SolverInterface.SolverInterface (convert(solver_name), convert(configuration_file_name), solver_process_index, solver_process_size, communicator_ptr)
        else:
            self.thisptr = new SolverInterface.SolverInterface (convert(solver_name), convert(configuration_file_name), solver_process_index, solver_process_size)
        pass

    # destructor
    def __dealloc__ (self):
        del self.thisptr

    # steering methods
    ## @brief Fully initializes preCICE
    #
    #  @pre configure() has been called successfully.
    #  @pre initialize() has not yet been called.
    #
    #  @post Parallel communication to the coupling partner/s is setup.
    #  @post Meshes are exchanged between coupling partners and the parallel partitions are created.
    #  @post [Serial Coupling Scheme] If the solver is not starting the simulation, coupling data is received
    #  from the coupling partner's first computation.
    #
    #  @return Maximum length of first timestep to be computed by the solver.
    #
    def initialize (self):
        return self.thisptr.initialize ()

    ## @brief Initializes coupling data.
    #
    #  The starting values for coupling data are zero by default.
    #
    #  To provide custom values, first set the data using the Data Access methods and
    #  call this method to finally exchange the data.
    #
    #  \par Serial Coupling Scheme
    #  Only the first participant has to call this method, the second participant
    #  receives the values on calling initialize().
    #
    #  \par Parallel Coupling Scheme
    #  Values in both directions are exchanged.
    #  Both participants need to call initializeData().
    #
    #  @pre initialize() has been called successfully.
    #  @pre The action WriteInitialData is required
    #  @pre advance() has not yet been called.
    #  @pre finalize() has not yet been called.
    #
    #  @post Initial coupling data was exchanged.
    #
    #  @see Interface()::is_action_required()
    #  @see precice()::constants()::actionWriteInitialData()
    #
    def initialize_data (self):
        self.thisptr.initializeData ()

    ## @brief Advances preCICE after the solver has computed one timestep.
    #
    #  @param[in] computed_timestep_length Length of timestep used by the solver.
    #
    #  @pre initialize() has been called successfully.
    #  @pre The solver has computed one timestep.
    #  @pre The solver has written all coupling data.
    #  @pre finalize() has not yet been called.
    #
    #  @post Coupling data values specified in the configuration are exchanged.
    #  @post Coupling scheme state (computed time, computed timesteps, ...) is updated.
    #  @post The coupling state is logged.
    #  @post Configured data mapping schemes are applied.
    #  @post [Second Participant] Configured post processing schemes are applied.
    #  @post Meshes with data are exported to files if configured.
    #
    #  @return Maximum length of next timestep to be computed by solver.
    #
    def advance (self, double computed_timestep_length):
        return self.thisptr.advance (computed_timestep_length)

    ## @brief Finalizes preCICE.
    #
    #  @pre initialize() has been called successfully.
    #
    #  @post Communication channels are closed.
    #  @post Meshes and data are deallocated
    #
    #  @see is_coupling_ongoing()
    #
    def finalize (self):
        self.thisptr.finalize ()

    # status queries
    ## @brief Returns the number of spatial dimensions configured.
    #
    #  @returns the configured dimension
    #
    #  Currently, two and three dimensional problems can be solved using preCICE.
    #  The dimension is specified in the XML configuration.
    #
    #  @pre configure() has been called successfully.
    #
    def get_dimensions (self):
        return self.thisptr.getDimensions ()

    ## @brief Checks if the coupled simulation is still ongoing.
    #
    #  @returns whether the coupling is ongoing.
    #
    #  A coupling is ongoing as long as
    #  - the maximum number of timesteps has not been reached, and
    #  - the final time has not been reached.
    #
    #  @pre initialize() has been called successfully.
    #
    #  @see advance()
    #
    #  @note
    #  The user should call finalize() after this function returns false.
    #
    def is_coupling_ongoing (self):
        return self.thisptr.isCouplingOngoing ()

    ## @brief Checks if new data to be read is available.
    #
    #  @returns whether new data is available to be read.
    #
    #  Data is classified to be new, if it has been received while calling
    #  initialize() and before calling advance(), or in the last call of advance().
    #  This is always true, if a participant does not make use of subcycling, i.e.
    #  choosing smaller timesteps than the limits returned in intitialize() and
    #  advance().
    #
    #  @pre initialize() has been called successfully.
    #
    #  @note
    #  It is allowed to read data even if this function returns false.
    #  This is not recommended due to performance reasons.
    #  Use this function to prevent unnecessary reads.
    #
    def is_read_data_available (self):
        return self.thisptr.isReadDataAvailable ()

    ## @brief Checks if new data has to be written before calling advance().
    #
    #  @param[in] computed_timestep_length Length of timestep used by the solver.
    #
    #  @return whether new data has to be written.
    #
    #  This is always true, if a participant does not make use of subcycling, i.e.
    #  choosing smaller timesteps than the limits returned in intitialize() and
    #  advance().
    #
    #  @pre initialize() has been called successfully.
    #
    #  @note
    #  It is allowed to write data even if this function returns false.
    #  This is not recommended due to performance reasons.
    #  Use this function to prevent unnecessary writes.
    #
    def is_write_data_required (self, double computed_timestep_length):
        return self.thisptr.isWriteDataRequired (computed_timestep_length)

    ## @brief Checks if the current coupling timewindow is completed.
    #
    #  @returns whether the timestep is complete.
    #
    #  The following reasons require several solver time steps per coupling time
    #  step:
    #  - A solver chooses to perform subcycling.
    #  - An implicit coupling timestep iteration is not yet converged.
    #
    #  @pre initialize() has been called successfully.
    #
    def is_time_window_complete (self):
        return self.thisptr.isTimeWindowComplete ()

    ## @brief Returns whether the solver has to evaluate the surrogate model representation.
    #
    #  @deprecated
    #  Only necessary for deprecated manifold mapping.
    #
    #  @returns whether the surrogate model has to be evaluated.
    #
    #  @note
    #  The solver may still have to evaluate the fine model representation.
    #
    #  @see has_to_evaluate_fine_model()
    #
    def has_to_evaluate_surrogate_model (self):
        return self.thisptr.hasToEvaluateSurrogateModel ()

    ## @brief Checks if the solver has to evaluate the fine model representation.
    #
    #  @deprecated
    #  Only necessary for deprecated manifold mapping.
    #
    #  @returns whether the fine model has to be evaluated.
    #
    #  @note
    #  The solver may still have to evaluate the surrogate model representation.
    #
    #  @see has_to_evaluate_surrogate_model()
    #
    def has_to_evaluate_fine_model (self):
        return self.thisptr.hasToEvaluateFineModel ()

    # action methods
    ## @brief Checks if the provided action is required.
    #
    #  @param[in] action the name of the action
    #  @returns whether the action is required
    #
    #  Some features of preCICE require a solver to perform specific actions, in
    #  order to be in valid state for a coupled simulation. A solver is made
    #  eligible to use those features, by querying for the required actions,
    #  performing them on demand, and calling fulfilledAction() to signalize
    #  preCICE the correct behavior of the solver.
    #
    #  @see fulfilled_action()
    #  @see cplscheme::constants
    #
    def is_action_required (self, action):
        return self.thisptr.isActionRequired (action)

    ## @brief Indicates preCICE that a required action has been fulfilled by a solver.
    #
    #  @pre The solver fulfilled the specified action.
    #
    #  @param[in] action the name of the action
    #
    #  @see require_action()
    #  @see cplscheme::constants
    #
    def mark_action_fulfilled (self, action):
        self.thisptr.markActionFulfilled (action)

    # mesh access
    ## @brief Checks if the mesh with given name is used by a solver.
    #
    #  @param[in] mesh_name the name of the mesh
    #  @returns whether the mesh is used.
    #
    def has_mesh(self, mesh_name):
        return self.thisptr.hasMesh (convert(mesh_name))

    ## @brief Returns the ID belonging to the mesh with given name.
    #
    #  @param[in] mesh_name the name of the mesh
    #  @returns the id of the corresponding mesh
    #
    def get_mesh_id (self, mesh_name):
        return self.thisptr.getMeshID (convert(mesh_name))

    ## @brief Returns a id-set of all used meshes by this participant.
    #
    #  @returns the set of ids.
    #
    def get_mesh_ids (self):
        return self.thisptr.getMeshIDs ()

    ## @brief Returns a handle to a created mesh.
    #
    #  @param[in] mesh_name the name of the mesh
    #  @returns the handle to the mesh
    #
    #  @see precice::MeshHandle
    #
    def get_mesh_handle(self, mesh_name):
        raise Exception("The API method get_mesh_handle is not yet available for the Python bindings.")

    ## @brief Creates a mesh vertex
    #
    #  @param[in] mesh_id the id of the mesh to add the vertex to.
    #  @param[in] position a pointer to the coordinates of the vertex.
    #  @returns the id of the created vertex
    #
    #  @pre initialize() has not yet been called
    #  @pre count of available elements at position matches the configured dimension
    #
    #  @see get_dimensions()
    #
    def set_mesh_vertex(self, mesh_id, position):
        if not isinstance(position, np.ndarray):
            position = np.asarray(position)
        dimensions = position.size
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[double, ndim=1] _position = np.ascontiguousarray(position, dtype=np.double)
        vertex_id = self.thisptr.setMeshVertex(mesh_id, <const double*>_position.data)
        return vertex_id

    ## @brief Returns the number of vertices of a mesh.
    #
    #  @param[in] mesh_id the id of the mesh
    #  @returns the amount of the vertices of the mesh
    #
    def get_mesh_vertex_size (self, mesh_id):
        return self.thisptr.getMeshVertexSize(mesh_id)

    ## @brief Creates multiple mesh vertices
    #
    #  @param[in] mesh_id the id of the mesh to add the vertices to.
    #  @param[in] size Number of vertices to create
    #  @param[in] positions a pointer to the coordinates of the vertices
    #             The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny)
    #             The 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz)
    #
    #  @param[out] ids The ids of the created vertices
    #
    #  @pre initialize() has not yet been called
    #  @pre count of available elements at positions matches the configured dimension * size
    #  @pre count of available elements at ids matches size
    #
    #  @see get_dimensions()
    #
    def set_mesh_vertices (self, mesh_id, positions):
        if not isinstance(positions, np.ndarray):
            positions = np.asarray(positions)
        size, dimensions = positions.shape
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[double, ndim=1] _positions = np.ascontiguousarray(positions.flatten(), dtype=np.double)
        cdef np.ndarray[int, ndim=1] _ids = np.empty(size, dtype=np.int32)
        self.thisptr.setMeshVertices (mesh_id, size, <const double*>_positions.data, <int*>_ids.data)
        return _ids

    ## @brief Get vertex positions for multiple vertex ids from a given mesh
    #
    #  @param[in] mesh_id the id of the mesh to read the vertices from.
    #  @param[in] size Number of vertices to lookup
    #  @param[in] ids The ids of the vertices to lookup
    #  @param[out] positions a pointer to memory to write the coordinates to
    #             The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny)
    #             The 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz)
    #
    #  @pre count of available elements at positions matches the configured dimension * size
    #  @pre count of available elements at ids matches size
    #
    #  @see get_dimensions()
    #
    def get_mesh_vertices(self, mesh_id, ids):
        cdef np.ndarray[int, ndim=1] _ids = np.ascontiguousarray(ids, dtype=np.int32)
        size = _ids.size
        cdef np.ndarray[double, ndim=1] _positions = np.empty(size * self.get_dimensions(), dtype=np.double)
        self.thisptr.getMeshVertices (mesh_id, size, <const int*>_ids.data, <double*>_positions.data)
        return _positions.reshape((size, self.get_dimensions()))

    ## @brief Gets mesh vertex IDs from positions.
    #
    #  @param[in] mesh_id ID of the mesh to retrieve positions from
    #  @param[in] size Number of vertices to lookup.
    #  @param[in] positions Positions to find ids for.
    #             The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny)
    #             The 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz)
    #  @param[out] ids IDs corresponding to positions.
    #
    #  @pre count of available elements at positions matches the configured dimension * size
    #  @pre count of available elements at ids matches size
    #
    #  @note prefer to reuse the IDs returned from calls to set_mesh_vertex() and set_mesh_vertices().
    #
    def get_mesh_vertex_ids_from_positions (self, mesh_id, positions):
        if not isinstance(positions, np.ndarray):
            positions = np.asarray(positions)
        size, dimensions = positions.shape
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[double, ndim=1] _positions = np.ascontiguousarray(positions.flatten(), dtype=np.double)
        cdef np.ndarray[int, ndim=1] _ids = np.empty(int(size), dtype=np.int32)
        self.thisptr.getMeshVertexIDsFromPositions (mesh_id, size, <const double*>_positions.data, <int*>_ids.data)
        return _ids

    ## @brief Sets mesh edge from vertex IDs, returns edge ID.
    #
    #  @param[in] mesh_id ID of the mesh to add the edge to
    #  @param[in] firstVertexID ID of the first vertex of the edge
    #  @param[in] secondVertexID ID of the second vertex of the edge
    #
    #  @return the ID of the edge
    #
    #  @pre vertices with firstVertexID and secondVertexID were added to the mesh with the ID meshID
    #
    def set_mesh_edge (self, mesh_id, first_vertex_id, second_vertex_id):
        return self.thisptr.setMeshEdge (mesh_id, first_vertex_id, second_vertex_id)

    ## @brief Sets mesh triangle from edge IDs
    #
    #  @param[in] mesh_id ID of the mesh to add the triangle to
    #  @param[in] first_edge_id ID of the first edge of the triangle
    #  @param[in] second_edge_id ID of the second edge of the triangle
    #  @param[in] third_edge_id ID of the third edge of the triangle
    #
    #  @pre edges with first_edge_id, second_edge_id, and third_edge_id were added to the mesh with the ID meshID
    #
    def set_mesh_triangle (self, mesh_id, first_edge_id, second_edge_id, third_edge_id):
        self.thisptr.setMeshTriangle (mesh_id, first_edge_id, second_edge_id, third_edge_id)

    ## @brief Sets mesh triangle from vertex IDs.
    #
    #  @warning
    #  This routine is supposed to be used, when no edge information is available
    #  per se. Edges are created on the fly within preCICE. This routine is
    #  significantly slower than the one using edge IDs, since it needs to check,
    #  whether an edge is created already or not.
    #
    #  @param[in] mesh_id ID of the mesh to add the triangle to
    #  @param[in] first_vertex_id ID of the first vertex of the triangle
    #  @param[in] second_vertex_id ID of the second vertex of the triangle
    #  @param[in] third_vertex_id ID of the third vertex of the triangle
    #
    #  @pre edges with first_vertex_id, second_vertex_id, and third_vertex_id were added to the mesh with the ID meshID
    #
    def set_mesh_triangle_with_edges (self, mesh_id, first_vertex_id, second_vertex_id, third_vertex_id):
        self.thisptr.setMeshTriangleWithEdges (mesh_id, first_vertex_id, second_vertex_id, third_vertex_id)

    ## @brief Sets mesh Quad from edge IDs.
    #
    #  @param[in] mesh_id ID of the mesh to add the Quad to
    #  @param[in] first_edge_id ID of the first edge of the Quad
    #  @param[in] second_edge_id ID of the second edge of the Quad
    #  @param[in] third_edge_id ID of the third edge of the Quad
    #  @param[in] fourth_edge_id ID of the forth edge of the Quad
    #
    #  @pre edges with first_edge_id, second_edge_id, third_edge_id, and fourth_edge_id were added to the mesh with the ID mesh_id
    #
    #  @warning Quads are not fully implemented yet.
    #
    def set_mesh_quad (self, mesh_id, first_edge_id, second_edge_id, third_edge_id, fourth_edge_id):
        self.thisptr.setMeshQuad (mesh_id, first_edge_id, second_edge_id, third_edge_id, fourth_edge_id)

    ## @brief Sets surface mesh quadrangle from vertex IDs.
    #
    #  @warning
    #  This routine is supposed to be used, when no edge information is available
    #  per se. Edges are created on the fly within preCICE. This routine is
    #  significantly slower than the one using edge IDs, since it needs to check,
    #  whether an edge is created already or not.
    #
    #  @param[in] mesh_id ID of the mesh to add the Quad to
    #  @param[in] first_vertex_id ID of the first vertex of the Quad
    #  @param[in] second_vertex_id ID of the second vertex of the Quad
    #  @param[in] third_vertex_id ID of the third vertex of the Quad
    #  @param[in] fourth_vertex_id ID of the fourth vertex of the Quad
    #
    #  @pre edges with first_vertex_id, second_vertex_id, third_vertex_id, and fourth_vertex_id were added to the mesh with the ID mesh_id
    #
    def set_mesh_quad_with_edges (self, mesh_id, first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id):
        self.thisptr.setMeshQuadWithEdges (mesh_id, first_vertex_id, second_vertex_id, third_vertex_id, fourth_vertex_id)

    # data access
    ## @brief Checks if the data with given name is used by a solver and mesh.
    #
    #  @param[in] data_name the name of the data
    #  @param[in] mesh_id the id of the associated mesh
    #  @returns whether the mesh is used.
    #
    def has_data (self, str data_name, mesh_id):
        return self.thisptr.hasData(convert(data_name), mesh_id)

    ## @brief Returns the ID of the data associated with the given name and mesh.
    #
    #  @param[in] data_name the name of the data
    #  @param[in] mesh_id the id of the associated mesh
    #
    #  @returns the id of the corresponding data
    #
    def get_data_id (self, str data_name, mesh_id):
        return self.thisptr.getDataID (convert(data_name), mesh_id)

    ## @brief Computes and maps all read data mapped to the mesh with given ID.
    #
    #  This is an explicit request to map read data to the Mesh associated with toMeshID.
    #  It also computes the mapping if necessary.
    #
    #  @pre A mapping to to_mesh_id was configured.
    #
    def map_read_data_to (self, to_mesh_id):
        self.thisptr.mapReadDataTo (to_mesh_id)

    ## @brief Computes and maps all write data mapped from the mesh with given ID.
    #
    #  This is an explicit request to map write data from the Mesh associated with fromMeshID.
    #  It also computes the mapping if necessary.
    #
    #  @pre A mapping from from_mesh_id was configured.
    #
    def map_write_data_from (self, from_mesh_id):
        self.thisptr.mapWriteDataFrom (from_mesh_id)

    ## @brief Writes vector data given as block.
    #
    #  This function writes values of specified vertices to a dataID.
    #  Values are provided as a block of continuous memory.
    #  valueIndices contains the indices of the vertices
    #
    #  The 2D-format of values is (d0x, d0y, d1x, d1y, ..., dnx, dny)
    #  The 3D-format of values is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz)
    #
    #  @param[in] data_id ID to write to.
    #  @param[in] value_indices Indices of the vertices.
    #  @param[in] values pointer to the vector values.
    #
    #  @pre count of available elements at values matches the configured dimension * size
    #  @pre count of available elements at valueIndices matches the given size
    #  @pre initialize() has been called
    #
    #  @see Interface::set_mesh_vertex()
    def write_block_vector_data (self, data_id, value_indices, values):
        if not isinstance(values, np.ndarray):
            values = np.asarray(values)
        size, dimensions = values.shape
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[int, ndim=1] _value_indices = np.ascontiguousarray(value_indices, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _values = np.ascontiguousarray(values.flatten(), dtype=np.double)
        assert(size == _value_indices.size)
        size = value_indices.size
        self.thisptr.writeBlockVectorData (data_id, size, <const int*>_value_indices.data, <const double*>_values.data)

    ## @brief Writes vector data to a vertex
    #
    #  This function writes a value of a specified vertex to a dataID.
    #  Values are provided as a block of continuous memory.
    #
    #  The 2D-format of value is (x, y)
    #  The 3D-format of value is (x, y, z)
    #
    #  @param[in] data_id ID to write to.
    #  @param[in] value_index Index of the vertex.
    #  @param[in] value pointer to the vector value.
    #
    #  @pre count of available elements at value matches the configured dimension
    #  @pre initialize() has been called
    #
    #  @see Interface::set_mesh_vertex()
    #
    def write_vector_data (self, data_id, value_index, value):
        if not isinstance(value, np.ndarray):
            value = np.asarray(value)
        dimensions = value.size
        assert(dimensions == self.get_dimensions())
        cdef np.ndarray[np.double_t, ndim=1] _value = np.ascontiguousarray(value, dtype=np.double)
        self.thisptr.writeVectorData (data_id, value_index, <const double*>_value.data)

    ## @brief Writes scalar data given as block.
    #
    #  This function writes values of specified vertices to a dataID.
    #  Values are provided as a block of continuous memory.
    #  valueIndices contains the indices of the vertices
    #
    #  @param[in] data_id ID to write to.
    #  @param[in] value_indices Indices of the vertices.
    #  @param[in] values pointer to the values.
    #
    #  @pre count of available elements at values matches the given size
    #  @pre count of available elements at valueIndices matches the given size
    #  @pre initialize() has been called
    #
    #  @see Interface::set_mesh_vertex()
    #
    def write_block_scalar_data (self, data_id, value_indices, values):
        cdef np.ndarray[int, ndim=1] _value_indices = np.ascontiguousarray(value_indices, dtype=np.int32)
        cdef np.ndarray[double, ndim=1] _values = np.ascontiguousarray(values, dtype=np.double)
        assert(_values.size == _value_indices.size)
        size = value_indices.size
        self.thisptr.writeBlockScalarData (data_id, size, <const int*>_value_indices.data, <const double*>_values.data)

    ##  @brief Writes scalar data to a vertex
    #
    #  This function writes a value of a specified vertex to a dataID.
    #
    #  @param[in] data_id ID to write to.
    #  @param[in] value_index Index of the vertex.
    #  @param[in] value the value to write.
    #
    #  @pre initialize() has been called
    #
    #  @see Interface::set_mesh_vertex()
    #
    def write_scalar_data (self, data_id, value_index, double value):
        self.thisptr.writeScalarData (data_id, value_index, value)

    ## @brief Reads vector data into a provided block.
    #
    #  This function reads values of specified vertices from a dataID.
    #  Values are read into a block of continuous memory.
    #  valueIndices contains the indices of the vertices.
    #
    #  The 2D-format of values is (d0x, d0y, d1x, d1y, ..., dnx, dny)
    #  The 3D-format of values is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz)
    #
    #  @param[in] data_id ID to read from.
    #  @param[in] value_indices Indices of the vertices.
    #
    #  @pre count of available elements at values matches the configured dimension * size
    #  @pre count of available elements at valueIndices matches the given size
    #  @pre initialize() has been called
    #
    #  @post values contain the read data as specified in the above format.
    #
    #  @see Interface::set_mesh_vertex()
    #
    def read_block_vector_data (self, data_id, value_indices):
        cdef np.ndarray[int, ndim=1] _value_indices = np.ascontiguousarray(value_indices, dtype=np.int32)
        size = _value_indices.size
        dimensions = self.get_dimensions()
        cdef np.ndarray[np.double_t, ndim=1] _values = np.empty(size * dimensions, dtype=np.double)
        self.thisptr.readBlockVectorData (data_id, size, <const int*>_value_indices.data, <double*>_values.data)
        return _values.reshape((size, dimensions))

    ## @brief Reads vector data form a vertex
    #
    #  This function reads a value of a specified vertex from a dataID.
    #  Values are provided as a block of continuous memory.
    #
    #  The 2D-format of value is (x, y)
    #  The 3D-format of value is (x, y, z)
    #
    #  @param[in] data_id ID to read from.
    #  @param[in] value_index Index of the vertex.
    #
    #  @pre count of available elements at value matches the configured dimension
    #  @pre initialize() has been called
    #
    #  @post value contains the read data as specified in the above format.
    #
    #  @see Interface::set_mesh_vertex()
    #
    def read_vector_data (self, data_id, value_index):
        dimensions = self.get_dimensions()
        cdef np.ndarray[double, ndim=1] _value = np.empty(dimensions, dtype=np.double)
        self.thisptr.readVectorData (data_id, value_index, <double*>_value.data)
        return _value

    ## @brief Reads scalar data as a block.
    #
    #  This function reads values of specified vertices from a dataID.
    #  Values are provided as a block of continuous memory.
    #  valueIndices contains the indices of the vertices.
    #
    #  @param[in] data_id ID to read from.
    #  @param[in] value_indices Indices of the vertices.
    #
    #  @pre count of available elements at values matches the given size
    #  @pre count of available elements at valueIndices matches the given size
    #  @pre initialize() has been called
    #
    #  @post values contains the read data.
    #
    #  @see Interface::set_mesh_vertex()
    #
    def read_block_scalar_data (self, data_id, value_indices):
        cdef np.ndarray[int, ndim=1] _value_indices = np.ascontiguousarray(value_indices, dtype=np.int32)
        size = _value_indices.size
        cdef np.ndarray[double, ndim=1] _values = np.empty(size, dtype=np.double)
        self.thisptr.readBlockScalarData (data_id, size, <const int*>_value_indices.data, <double*>_values.data)
        return _values

    ## @brief Reads scalar data of a vertex.
    #
    #  This function reads a value of a specified vertex from a dataID.
    #
    #  @param[in] data_id ID to read from.
    #  @param[in] value_index Index of the vertex.
    #
    #  @pre initialize() has been called
    #
    #  @post value contains the read data.
    #
    #  @see Interface::set_mesh_vertex()
    #
    def read_scalar_data (self, data_id, value_index):
        cdef double _value
        self.thisptr.readScalarData (data_id, value_index, _value)
        return _value

## @brief Current preCICE version information.
def get_version_information ():
    return SolverInterface.getVersionInformation()

## @brief Name of action for writing initial data.
def action_write_initial_data ():
    return SolverInterface.actionWriteInitialData()

## @brief Name of action for writing iteration checkpoint.
def action_write_iteration_checkpoint ():
    return SolverInterface.actionWriteIterationCheckpoint()

## @brief Name of action for reading iteration checkpoint.
def action_read_iteration_checkpoint ():
    return SolverInterface.actionReadIterationCheckpoint()
