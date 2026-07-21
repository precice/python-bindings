import os

import precice
from unittest import TestCase
import numpy as np
from mpi4py import MPI

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "precice-config.xml")

# Names defined in test/precice-config.xml
PARTICIPANT_NAME = "test"
MESH_NAME = "FakeMesh"
MESH_DIMENSIONS = 3
SCALAR_WRITE_DATA = "FakeScalarData"
SCALAR_READ_DATA = "FakeScalarReadData"
VECTOR_WRITE_DATA = "FakeVectorData"
VECTOR_READ_DATA = "FakeVectorReadData"
DIRECT_ACCESS_MESH = "PartnerMesh"
JIT_WRITE_DATA = "JitWriteData"
JIT_READ_DATA = "JitReadData"
BOUNDING_BOX = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0]
# The universal preCICE mock synthesizes this many vertices for a received mesh
# after set_mesh_access_region() has been called (see extras/mock in the preCICE
# repository).
N_DIRECT_ACCESS_VERTICES = 10

TIME_WINDOW_SIZE = 1.0
MAX_TIME_WINDOWS = 2


class TestBindings(TestCase):
    """
    Test suite to check correct behaviour of python bindings.

    The tests run against the universal preCICE mock (libpreciceMocked.so from
    extras/mock in the preCICE repository), which is loaded via LD_PRELOAD. The
    mock parses test/precice-config.xml and validates all API calls against it.
    Data written via write_data is buffered by the mock and echoed back by
    read_data.
    """

    def _participant(self):
        return precice.Participant(PARTICIPANT_NAME, CONFIG_PATH, 0, 1)

    def _initialized_participant(self, n_vertices=3):
        """
        Returns a participant with n_vertices vertices set on MESH_NAME and
        initialize() already called, plus the corresponding vertex ids.
        """
        participant = self._participant()
        positions = np.random.rand(n_vertices, MESH_DIMENSIONS)
        vertex_ids = participant.set_mesh_vertices(MESH_NAME, positions)
        participant.initialize()
        return participant, vertex_ids

    # construction and configuration

    def test_constructor(self):
        participant = self._participant()
        self.assertIsNotNone(participant)

    def test_constructor_custom_mpi_comm(self):
        participant = precice.Participant(
            PARTICIPANT_NAME, CONFIG_PATH, 0, 1, MPI.COMM_WORLD
        )
        self.assertIsNotNone(participant)

    def test_constructor_unknown_participant(self):
        with self.assertRaises(RuntimeError):
            precice.Participant("UnknownParticipant", CONFIG_PATH, 0, 1)

    def test_constructor_missing_config(self):
        with self.assertRaises(RuntimeError):
            precice.Participant(PARTICIPANT_NAME, "missing-config.xml", 0, 1)

    def test_version(self):
        precice.__version__

    def test_get_version_information(self):
        version_info = precice.get_version_information()
        self.assertIn(b"precice-mock", version_info)

    # status queries

    def test_get_mesh_dimensions(self):
        participant = self._participant()
        self.assertEqual(MESH_DIMENSIONS, participant.get_mesh_dimensions(MESH_NAME))

    def test_get_mesh_dimensions_unknown_mesh(self):
        participant = self._participant()
        with self.assertRaises(RuntimeError):
            participant.get_mesh_dimensions("UnknownMesh")

    def test_get_data_dimensions(self):
        participant = self._participant()
        self.assertEqual(
            1, participant.get_data_dimensions(MESH_NAME, SCALAR_WRITE_DATA)
        )
        self.assertEqual(
            MESH_DIMENSIONS,
            participant.get_data_dimensions(MESH_NAME, VECTOR_WRITE_DATA),
        )

    def test_get_data_dimensions_unknown_data(self):
        participant = self._participant()
        with self.assertRaises(RuntimeError):
            participant.get_data_dimensions(MESH_NAME, "UnknownData")

    def test_requires_initial_data(self):
        participant = self._participant()
        self.assertFalse(participant.requires_initial_data())

    def test_requires_checkpoints(self):
        # explicit coupling scheme: no checkpoints are required
        participant, _ = self._initialized_participant()
        self.assertFalse(participant.requires_writing_checkpoint())
        self.assertFalse(participant.requires_reading_checkpoint())

    # steering methods

    def test_initialize_without_vertices_raises(self):
        participant = self._participant()
        with self.assertRaises(RuntimeError):
            participant.initialize()

    def test_simulation_loop(self):
        participant, vertex_ids = self._initialized_participant()
        n_time_windows = 0
        while participant.is_coupling_ongoing():
            dt = participant.get_max_time_step_size()
            self.assertEqual(TIME_WINDOW_SIZE, dt)
            write_data = np.random.rand(len(vertex_ids))
            participant.write_data(MESH_NAME, SCALAR_WRITE_DATA, vertex_ids, write_data)
            participant.advance(dt)
            self.assertTrue(participant.is_time_window_complete())
            n_time_windows += 1
        self.assertEqual(MAX_TIME_WINDOWS, n_time_windows)
        participant.finalize()

    def test_subcycling(self):
        participant, _ = self._initialized_participant()
        participant.advance(TIME_WINDOW_SIZE / 2)
        self.assertFalse(participant.is_time_window_complete())
        participant.advance(TIME_WINDOW_SIZE / 2)
        self.assertTrue(participant.is_time_window_complete())

    def test_advance_exceeding_time_window_raises(self):
        participant, _ = self._initialized_participant()
        with self.assertRaises(RuntimeError):
            participant.advance(2 * TIME_WINDOW_SIZE)

    # mesh access

    def test_requires_mesh_connectivity_for(self):
        participant = self._participant()
        # the partner participant defines a projection-based mapping from
        # FakeMesh, so connectivity is required for it
        self.assertTrue(participant.requires_mesh_connectivity_for(MESH_NAME))
        self.assertFalse(participant.requires_mesh_connectivity_for(DIRECT_ACCESS_MESH))

    def test_reset_mesh(self):
        participant, _ = self._initialized_participant()
        participant.reset_mesh(MESH_NAME)
        # after resetting, the mesh may be redefined from scratch
        positions = np.random.rand(4, MESH_DIMENSIONS)
        vertex_ids = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertTrue(np.array_equal(np.arange(4), vertex_ids))

    def test_set_mesh_vertices(self):
        participant = self._participant()
        n_vertices = 3
        positions = np.random.rand(n_vertices, MESH_DIMENSIONS)
        expected_output = np.array(range(n_vertices))
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty(self):
        participant = self._participant()
        positions = np.zeros((0, MESH_DIMENSIONS))
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertEqual(0, len(actual_output))

    def test_set_mesh_vertices_list(self):
        participant = self._participant()
        n_vertices = 3
        positions = np.random.rand(n_vertices, MESH_DIMENSIONS)
        positions = list(
            list(positions[i, j] for j in range(positions.shape[1]))
            for i in range(positions.shape[0])
        )
        expected_output = np.array(range(n_vertices))
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty_list(self):
        participant = self._participant()
        positions = []
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertEqual(0, len(actual_output))

    def test_set_mesh_vertices_tuple(self):
        participant = self._participant()
        n_vertices = 3
        positions = np.random.rand(n_vertices, MESH_DIMENSIONS)
        positions = tuple(
            tuple(positions[i, j] for j in range(positions.shape[1]))
            for i in range(positions.shape[0])
        )
        expected_output = np.array(range(n_vertices))
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty_tuple(self):
        participant = self._participant()
        positions = ()
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertEqual(0, len(actual_output))

    def test_set_mesh_vertices_mixed(self):
        participant = self._participant()
        n_vertices = 3
        positions = np.random.rand(n_vertices, MESH_DIMENSIONS)
        positions = list(
            tuple(positions[i, j] for j in range(positions.shape[1]))
            for i in range(positions.shape[0])
        )
        expected_output = np.array(range(n_vertices))
        actual_output = participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_after_initialize_raises(self):
        participant, _ = self._initialized_participant()
        positions = np.random.rand(3, MESH_DIMENSIONS)
        with self.assertRaises(RuntimeError):
            participant.set_mesh_vertices(MESH_NAME, positions)

    def test_set_mesh_vertex(self):
        participant = self._participant()
        position = np.random.rand(MESH_DIMENSIONS)
        vertex_id = participant.set_mesh_vertex(MESH_NAME, position)
        self.assertEqual(0, vertex_id)

    def test_set_mesh_vertex_list(self):
        participant = self._participant()
        position = list(np.random.rand(MESH_DIMENSIONS))
        vertex_id = participant.set_mesh_vertex(MESH_NAME, position)
        self.assertEqual(0, vertex_id)

    def test_set_mesh_vertex_tuple(self):
        participant = self._participant()
        position = tuple(np.random.rand(MESH_DIMENSIONS))
        vertex_id = participant.set_mesh_vertex(MESH_NAME, position)
        self.assertEqual(0, vertex_id)

    def test_set_mesh_vertex_wrong_dimensions(self):
        participant = self._participant()
        # an empty position is rejected by the mock
        with self.assertRaises(RuntimeError):
            participant.set_mesh_vertex(MESH_NAME, [])
        # a position of wrong dimensionality is rejected by the bindings
        with self.assertRaises(AssertionError):
            participant.set_mesh_vertex(MESH_NAME, np.random.rand(2))

    def test_get_mesh_vertex_size(self):
        participant = self._participant()
        n_vertices = 3
        positions = np.random.rand(n_vertices, MESH_DIMENSIONS)
        participant.set_mesh_vertices(MESH_NAME, positions)
        self.assertEqual(n_vertices, participant.get_mesh_vertex_size(MESH_NAME))

    # connectivity

    def test_set_mesh_edge(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        participant.set_mesh_edge(MESH_NAME, 0, 1)

    def test_set_mesh_edge_invalid_vertex_raises(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        with self.assertRaises(RuntimeError):
            participant.set_mesh_edge(MESH_NAME, 0, 42)

    def test_set_mesh_edges(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        vertices = np.array([[0, 1], [1, 2]])
        participant.set_mesh_edges(MESH_NAME, vertices)

    def test_set_mesh_edges_empty(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        vertices = np.empty((0, 2), dtype=int)
        participant.set_mesh_edges(MESH_NAME, vertices)

    def test_set_mesh_triangle(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        participant.set_mesh_triangle(MESH_NAME, 0, 1, 2)

    def test_set_mesh_triangles(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(4, MESH_DIMENSIONS))
        vertices = np.array([[0, 1, 2], [1, 2, 3]])
        participant.set_mesh_triangles(MESH_NAME, vertices)

    def test_set_mesh_triangles_empty(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        vertices = np.empty((0, 3), dtype=int)
        participant.set_mesh_triangles(MESH_NAME, vertices)

    def test_set_mesh_quad(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(4, MESH_DIMENSIONS))
        participant.set_mesh_quad(MESH_NAME, 0, 1, 2, 3)

    def test_set_mesh_quads(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(5, MESH_DIMENSIONS))
        vertices = np.array([[0, 1, 2, 3], [1, 2, 3, 4]])
        participant.set_mesh_quads(MESH_NAME, vertices)

    def test_set_mesh_quads_empty(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(4, MESH_DIMENSIONS))
        vertices = np.empty((0, 4), dtype=int)
        participant.set_mesh_quads(MESH_NAME, vertices)

    def test_set_mesh_tetrahedron(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(4, MESH_DIMENSIONS))
        participant.set_mesh_tetrahedron(MESH_NAME, 0, 1, 2, 3)

    def test_set_mesh_tetrahedra(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(5, MESH_DIMENSIONS))
        vertices = np.array([[0, 1, 2, 3], [1, 2, 3, 4]])
        participant.set_mesh_tetrahedra(MESH_NAME, vertices)

    # data access

    def test_read_write_block_scalar_data(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = np.array([3, 7, 8], dtype=np.double)
        participant.write_data(MESH_NAME, SCALAR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, SCALAR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_scalar_data_single_float(self):
        participant = self._participant()
        write_data = 8
        with self.assertRaises(TypeError):
            participant.write_data(MESH_NAME, SCALAR_WRITE_DATA, 1, write_data)
        with self.assertRaises(TypeError):
            participant.read_data(MESH_NAME, SCALAR_READ_DATA, 1)

    def test_read_write_block_scalar_data_empty(self):
        participant, _ = self._initialized_participant()
        write_data = np.array([])
        participant.write_data(MESH_NAME, SCALAR_WRITE_DATA, [], write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, SCALAR_READ_DATA, [], dt)
        self.assertEqual(0, len(read_data))

    def test_read_write_block_scalar_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant, vertex_ids = self._initialized_participant()
        dummy_array = np.random.rand(3, 3)
        write_data = dummy_array[:, 1]
        assert write_data.flags["C_CONTIGUOUS"] is False
        participant.write_data(MESH_NAME, SCALAR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, SCALAR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_scalar_data(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = [3]
        participant.write_data(
            MESH_NAME, SCALAR_WRITE_DATA, [vertex_ids[0]], write_data
        )
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(
            MESH_NAME, SCALAR_READ_DATA, [vertex_ids[0]], dt
        )
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data(self):
        participant, vertex_ids = self._initialized_participant(n_vertices=2)
        write_data = np.array([[3, 7, 8], [7, 6, 5]], dtype=np.double)
        participant.write_data(MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, VECTOR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_empty(self):
        participant, _ = self._initialized_participant()
        write_data = np.array([])
        participant.write_data(MESH_NAME, VECTOR_WRITE_DATA, [], write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, VECTOR_READ_DATA, [], dt)
        self.assertEqual(0, len(read_data))

    def test_read_write_block_vector_data_list(self):
        participant, vertex_ids = self._initialized_participant(n_vertices=2)
        write_data = [[3.0, 7.0, 8.0], [7.0, 6.0, 5.0]]
        participant.write_data(MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, VECTOR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_tuple(self):
        participant, vertex_ids = self._initialized_participant(n_vertices=2)
        write_data = ((3.0, 7.0, 8.0), (7.0, 6.0, 5.0))
        participant.write_data(MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, VECTOR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_mixed(self):
        participant, vertex_ids = self._initialized_participant(n_vertices=2)
        write_data = [(3.0, 7.0, 8.0), (7.0, 6.0, 5.0)]
        participant.write_data(MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, VECTOR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        size = 6
        participant, vertex_ids = self._initialized_participant(n_vertices=size)
        dummy_array = np.random.rand(size, 5)
        write_data = dummy_array[:, 1:4]
        assert write_data.flags["C_CONTIGUOUS"] is False
        participant.write_data(MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, write_data)
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(MESH_NAME, VECTOR_READ_DATA, vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = np.array([[0, 1, 2]], dtype=np.double)
        participant.write_data(
            MESH_NAME, VECTOR_WRITE_DATA, [vertex_ids[0]], write_data
        )
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(
            MESH_NAME, VECTOR_READ_DATA, [vertex_ids[0]], dt
        )
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_list(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = [[0.0, 1.0, 2.0]]
        participant.write_data(
            MESH_NAME, VECTOR_WRITE_DATA, [vertex_ids[0]], write_data
        )
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(
            MESH_NAME, VECTOR_READ_DATA, [vertex_ids[0]], dt
        )
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_tuple(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = [(1.0, 2.0, 3.0)]
        participant.write_data(
            MESH_NAME, VECTOR_WRITE_DATA, [vertex_ids[0]], write_data
        )
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(
            MESH_NAME, VECTOR_READ_DATA, [vertex_ids[0]], dt
        )
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant, vertex_ids = self._initialized_participant()
        dummy_array = np.random.rand(3, 3)
        write_data = dummy_array[:, 1]
        assert write_data.flags["C_CONTIGUOUS"] is False
        write_data = [write_data]
        participant.write_data(
            MESH_NAME, VECTOR_WRITE_DATA, [vertex_ids[0]], write_data
        )
        dt = participant.get_max_time_step_size()
        read_data = participant.read_data(
            MESH_NAME, VECTOR_READ_DATA, [vertex_ids[0]], dt
        )
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_write_data_not_configured_for_writing_raises(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = np.random.rand(len(vertex_ids))
        with self.assertRaises(RuntimeError):
            participant.write_data(MESH_NAME, SCALAR_READ_DATA, vertex_ids, write_data)

    def test_read_data_not_configured_for_reading_raises(self):
        participant, vertex_ids = self._initialized_participant()
        dt = participant.get_max_time_step_size()
        with self.assertRaises(RuntimeError):
            participant.read_data(MESH_NAME, SCALAR_WRITE_DATA, vertex_ids, dt)

    def test_write_data_invalid_vertex_id_raises(self):
        participant, vertex_ids = self._initialized_participant()
        write_data = np.random.rand(len(vertex_ids))
        invalid_vertex_ids = np.copy(vertex_ids)
        invalid_vertex_ids[-1] = 42
        with self.assertRaises(RuntimeError):
            participant.write_data(
                MESH_NAME, SCALAR_WRITE_DATA, invalid_vertex_ids, write_data
            )

    def test_read_data_before_initialize_raises(self):
        participant = self._participant()
        vertex_ids = participant.set_mesh_vertices(
            MESH_NAME, np.random.rand(3, MESH_DIMENSIONS)
        )
        with self.assertRaises(RuntimeError):
            participant.read_data(MESH_NAME, SCALAR_READ_DATA, vertex_ids, 0.0)

    # just-in-time mapping

    def test_jit_mapping(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        participant.set_mesh_access_region(DIRECT_ACCESS_MESH, BOUNDING_BOX)
        participant.initialize()
        n_coordinates = 4
        coordinates = np.random.rand(n_coordinates, MESH_DIMENSIONS)
        write_data = np.random.rand(n_coordinates)
        participant.write_and_map_data(
            DIRECT_ACCESS_MESH, JIT_WRITE_DATA, coordinates, write_data
        )
        dt = participant.get_max_time_step_size()
        read_data = participant.map_and_read_data(
            DIRECT_ACCESS_MESH, JIT_READ_DATA, coordinates, dt
        )
        # the mock buffers data written via write_and_map_data and echoes it back
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_jit_mapping_without_access_region_raises(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        participant.initialize()
        coordinates = np.random.rand(4, MESH_DIMENSIONS)
        write_data = np.random.rand(4)
        with self.assertRaises(RuntimeError):
            participant.write_and_map_data(
                DIRECT_ACCESS_MESH, JIT_WRITE_DATA, coordinates, write_data
            )

    # direct access

    def test_set_mesh_access_region(self):
        participant = self._participant()
        participant.set_mesh_access_region(DIRECT_ACCESS_MESH, BOUNDING_BOX)

    def test_set_mesh_access_region_on_provided_mesh_raises(self):
        participant = self._participant()
        with self.assertRaises(RuntimeError):
            participant.set_mesh_access_region(MESH_NAME, BOUNDING_BOX)

    def test_get_mesh_vertex_ids_and_coordinates(self):
        participant = self._participant()
        participant.set_mesh_vertices(MESH_NAME, np.random.rand(3, MESH_DIMENSIONS))
        participant.set_mesh_access_region(DIRECT_ACCESS_MESH, BOUNDING_BOX)
        participant.initialize()
        vertex_ids, coordinates = participant.get_mesh_vertex_ids_and_coordinates(
            DIRECT_ACCESS_MESH
        )
        self.assertTrue(np.array_equal(np.arange(N_DIRECT_ACCESS_VERTICES), vertex_ids))
        self.assertEqual((N_DIRECT_ACCESS_VERTICES, MESH_DIMENSIONS), coordinates.shape)
        # the synthesized vertices lie inside the access region
        lower_bounds = np.array(BOUNDING_BOX[0::2])
        upper_bounds = np.array(BOUNDING_BOX[1::2])
        self.assertTrue(np.all(coordinates >= lower_bounds))
        self.assertTrue(np.all(coordinates <= upper_bounds))

    # gradient data

    def test_requires_gradient_data_for(self):
        participant = self._participant()
        # a gradient mapping is configured for write data on MESH_NAME
        self.assertTrue(
            participant.requires_gradient_data_for(MESH_NAME, SCALAR_WRITE_DATA)
        )
        self.assertTrue(
            participant.requires_gradient_data_for(MESH_NAME, VECTOR_WRITE_DATA)
        )
        # read data never requires gradient data
        self.assertFalse(
            participant.requires_gradient_data_for(MESH_NAME, SCALAR_READ_DATA)
        )

    def test_requires_gradient_data_for_unknown_data_raises(self):
        participant = self._participant()
        with self.assertRaises(RuntimeError):
            participant.requires_gradient_data_for(MESH_NAME, "UnknownData")

    def test_write_block_scalar_gradient_data(self):
        participant, vertex_ids = self._initialized_participant()
        gradients = np.random.rand(len(vertex_ids), MESH_DIMENSIONS)
        participant.write_gradient_data(
            MESH_NAME, SCALAR_WRITE_DATA, vertex_ids, gradients
        )

    def test_write_block_scalar_gradient_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant, vertex_ids = self._initialized_participant()
        dummy_array = np.random.rand(3, 9)
        gradients = dummy_array[:, 3:6]
        assert gradients.flags["C_CONTIGUOUS"] is False
        participant.write_gradient_data(
            MESH_NAME, SCALAR_WRITE_DATA, vertex_ids, gradients
        )

    def test_write_gradient_data_empty(self):
        participant, _ = self._initialized_participant()
        gradients = np.array([])
        participant.write_gradient_data(MESH_NAME, SCALAR_WRITE_DATA, [], gradients)

    def test_write_block_vector_gradient_data(self):
        participant, vertex_ids = self._initialized_participant(n_vertices=4)
        gradients = np.random.rand(len(vertex_ids), MESH_DIMENSIONS * MESH_DIMENSIONS)
        participant.write_gradient_data(
            MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, gradients
        )

    def test_write_block_vector_gradient_data_list(self):
        participant, vertex_ids = self._initialized_participant(n_vertices=2)
        gradients = [
            [3.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0],
            [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 6.0, 5.0],
        ]
        participant.write_gradient_data(
            MESH_NAME, VECTOR_WRITE_DATA, vertex_ids, gradients
        )

    def test_write_vector_gradient_data_tuple(self):
        participant, vertex_ids = self._initialized_participant()
        gradients = [(1.0, 2.0, 3.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0)]
        participant.write_gradient_data(
            MESH_NAME, VECTOR_WRITE_DATA, [vertex_ids[0]], gradients
        )

    # profiling

    def test_profiling_section(self):
        participant = self._participant()
        participant.start_profiling_section("my-section")
        participant.stop_last_profiling_section()
