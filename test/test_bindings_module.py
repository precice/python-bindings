import precice
from unittest import TestCase
import numpy as np
from mpi4py import MPI


class TestBindings(TestCase):
    """
    Test suite to check correct behaviour of python bindings.
    """

    def test_constructor(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        self.assertTrue(True)

    def test_constructor_custom_mpi_comm(self):
        solver_interface = precice.Interface(
            "test", "dummy.xml", 0, 1, MPI.COMM_WORLD)
        self.assertTrue(True)

    def test_version(self):
        precice.__version__

    def test_get_dimensions(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        # TODO: it would be nice to be able to mock the output of the interface
        # directly in the test, not in test/SolverInterface.hpp
        fake_dimension = 3  # compare to test/SolverInterface.hpp, fake_dimensions
        # TODO: it would be nice to be able to mock the output of the interface
        # directly in the test, not in test/SolverInterface.hpp
        self.assertEqual(fake_dimension, solver_interface.get_dimensions())

    def test_is_mesh_connectivity_required(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_bool = 0  # compare to output in test/SolverInterface.cpp
        fake_mesh_id = 0
        self.assertEqual(fake_bool, solver_interface.is_mesh_connectivity_required(fake_mesh_id))

    def test_get_mesh_id(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        # TODO: it would be nice to be able to mock the output of the interface
        # directly in the test, not in test/SolverInterface.hpp
        fake_mesh_id = 0  # compare to test/SolverInterface.hpp, fake_mesh_id
        actual_output = solver_interface.get_mesh_id("testMesh")
        self.assertEqual(fake_mesh_id, actual_output)

    def test_set_mesh_vertices(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 0  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = list(list(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        positions = []
        n_fake_vertices = 0
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = tuple(tuple(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        positions = ()
        n_fake_vertices = 0
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_mixed(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = list(tuple(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = solver_interface.set_mesh_vertices(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertex(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        position = np.random.rand(fake_dimension)
        vertex_id = solver_interface.set_mesh_vertex(fake_mesh_id, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_empty(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 0  # compare to test/SolverInterface.cpp, fake_dimensions
        position = np.random.rand(fake_dimension)
        vertex_id = solver_interface.set_mesh_vertex(fake_mesh_id, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        position = list(np.random.rand(fake_dimension))
        vertex_id = solver_interface.set_mesh_vertex(fake_mesh_id, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_empty_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        position = []
        vertex_id = solver_interface.set_mesh_vertex(fake_mesh_id, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        position = tuple(np.random.rand(fake_dimension))
        vertex_id = solver_interface.set_mesh_vertex(fake_mesh_id, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_empty_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        position = ()
        vertex_id = solver_interface.set_mesh_vertex(fake_mesh_id, position)
        self.assertTrue(0 == vertex_id)

    def test_get_mesh_vertex_ids_from_positions(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        fake_vertex_ids = range(n_fake_vertices)
        vertex_ids = solver_interface.get_mesh_vertex_ids_from_positions(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(fake_vertex_ids, vertex_ids))

    def test_get_mesh_vertex_ids_from_positions_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = list(list(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        fake_vertex_ids = range(n_fake_vertices)
        vertex_ids = solver_interface.get_mesh_vertex_ids_from_positions(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(fake_vertex_ids, vertex_ids))

    def test_get_mesh_vertex_ids_from_positions_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = tuple(tuple(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        fake_vertex_ids = range(n_fake_vertices)
        vertex_ids = solver_interface.get_mesh_vertex_ids_from_positions(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(fake_vertex_ids, vertex_ids))

    def test_get_mesh_vertex_ids_from_positions_mixed(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = list(tuple(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        fake_vertex_ids = range(n_fake_vertices)
        vertex_ids = solver_interface.get_mesh_vertex_ids_from_positions(fake_mesh_id, positions)
        self.assertTrue(np.array_equal(fake_vertex_ids, vertex_ids))

    def test_get_mesh_vertex_size(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        n_vertices = solver_interface.get_mesh_vertex_size(fake_mesh_id)
        self.assertTrue(n_fake_vertices == n_vertices)

    def test_get_mesh_vertices(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        fake_vertices = np.zeros((n_fake_vertices, fake_dimension))
        for i in range(n_fake_vertices):
            fake_vertices[i, 0] = i
            fake_vertices[i, 1] = i + n_fake_vertices
            fake_vertices[i, 2] = i + 2 * n_fake_vertices
        vertices = solver_interface.get_mesh_vertices(fake_mesh_id, range(n_fake_vertices))
        self.assertTrue(np.array_equal(fake_vertices, vertices))

    def test_read_write_block_scalar_data(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = np.array([3, 7, 8], dtype=np.double)
        solver_interface.write_block_scalar_data(1, np.array([1, 2, 3]), write_data)
        read_data = solver_interface.read_block_scalar_data(1, np.array([1, 2, 3]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_scalar_data_single_float(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = 8
        with self.assertRaises(TypeError):
            solver_interface.write_block_scalar_data(1, 1, write_data)
        with self.assertRaises(TypeError):
            solver_interface.read_block_scalar_data(1, 1)

    def test_read_write_block_scalar_data_empty(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = np.array([])
        solver_interface.write_block_scalar_data(1, [], write_data)
        read_data = solver_interface.read_block_scalar_data(1, [])
        self.assertTrue(len(read_data) == 0)

    def test_read_write_block_scalar_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(3, 3)
        write_data = dummy_array[:, 1]
        assert(write_data.flags["C_CONTIGUOUS"] is False)
        solver_interface.write_block_scalar_data(1, np.array([1, 2, 3]), write_data)
        read_data = solver_interface.read_block_scalar_data(1, np.array([1, 2, 3]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_scalar_data(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = 3
        solver_interface.write_scalar_data(1, 1, write_data)
        read_data = solver_interface.read_scalar_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = np.array([[3, 7, 8],
                               [7, 6, 5]], dtype=np.double)
        solver_interface.write_block_vector_data(1, np.array([1, 2]), write_data)
        read_data = solver_interface.read_block_vector_data(1, np.array([1, 2]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_empty(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = np.array([])
        solver_interface.write_block_vector_data(1, [], write_data)
        read_data = solver_interface.read_block_vector_data(1, [])
        self.assertTrue(len(read_data) == 0)

    def test_read_write_block_vector_data_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = [[3, 7, 8], [7, 6, 5]]
        solver_interface.write_block_vector_data(1, np.array([1, 2]), write_data)
        read_data = solver_interface.read_block_vector_data(1, np.array([1, 2]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = ((3, 7, 8), (7, 6, 5))
        solver_interface.write_block_vector_data(1, np.array([1, 2]), write_data)
        read_data = solver_interface.read_block_vector_data(1, np.array([1, 2]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_mixed(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = [(3, 7, 8), (7, 6, 5)]
        solver_interface.write_block_vector_data(1, np.array([1, 2]), write_data)
        read_data = solver_interface.read_block_vector_data(1, np.array([1, 2]))
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        size = 6
        dummy_array = np.random.rand(size, 5)
        write_data = dummy_array[:, 1:4]
        assert(write_data.flags["C_CONTIGUOUS"] is False)
        vertex_ids = np.arange(size)
        solver_interface.write_block_vector_data(1, vertex_ids, write_data)
        read_data = solver_interface.read_block_vector_data(1, vertex_ids)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = np.array([1, 2, 3], dtype=np.double)
        solver_interface.write_vector_data(1, 1, write_data)
        read_data = solver_interface.read_vector_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_list(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = [1, 2, 3]
        solver_interface.write_vector_data(1, 1, write_data)
        read_data = solver_interface.read_vector_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_tuple(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        write_data = (1, 2, 3)
        solver_interface.write_vector_data(1, 1, write_data)
        read_data = solver_interface.read_vector_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(3, 3)
        write_data = dummy_array[:, 1]
        assert(write_data.flags["C_CONTIGUOUS"] is False)
        solver_interface.write_vector_data(1, 1, write_data)
        read_data = solver_interface.read_vector_data(1, 1)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_get_data_id(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_data_name = "FakeData"  # compare to test/SolverInterface.cpp, fake_data_name
        fake_data_id = 15  # compare to test/SolverInterface.cpp, fake_data_ID
        data_id = solver_interface.get_data_id(fake_data_name, fake_mesh_id)
        self.assertTrue(data_id == fake_data_id)

    def test_get_version_information(self):
        version_info = precice.get_version_information()
        fake_version_info = b"dummy"  # compare to test/SolverInterface.cpp
        self.assertEqual(version_info, fake_version_info)

    def test_action_write_initial_data(self):
        return_constant = precice.action_write_initial_data()
        dummy_constant = b"dummy_write_initial_data"  # compare to test/SolverInterface.cpp
        self.assertEqual(return_constant, dummy_constant)

    def test_action_write_iteration_checkpoint(self):
        return_constant = precice.action_write_iteration_checkpoint()
        dummy_constant = b"dummy_write_iteration"  # compare to test/SolverInterface.cpp
        self.assertEqual(return_constant, dummy_constant)

    def test_action_read_iteration_checkpoint(self):
        return_constant = precice.action_read_iteration_checkpoint()
        dummy_constant = b"dummy_read_iteration"  # compare to test/SolverInterface.cpp
        self.assertEqual(return_constant, dummy_constant)

    def test_set_mesh_access_region(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        fake_bounding_box = np.arange(fake_dimension * 2)
        solver_interface.set_mesh_access_region(fake_mesh_id, fake_bounding_box)

    def test_get_mesh_vertices_and_ids(self):
        solver_interface = precice.Interface("test", "dummy.xml", 0, 1)
        fake_mesh_id = 0  # compare to test/SolverInterface.cpp, fake_mesh_id
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        vertex_ids = np.arange(n_fake_vertices)
        coordinates = np.zeros((n_fake_vertices, fake_dimension))
        for i in range(n_fake_vertices):
            coordinates[i, 0] = i * fake_dimension
            coordinates[i, 1] = i * fake_dimension + 1
            coordinates[i, 2] = i * fake_dimension + 2
        fake_ids, fake_coordinates = solver_interface.get_mesh_vertices_and_ids(fake_mesh_id)
        self.assertTrue(np.array_equal(fake_ids, vertex_ids))
        self.assertTrue(np.array_equal(fake_coordinates, coordinates))
