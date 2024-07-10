import precice
from unittest import TestCase
import numpy as np
from mpi4py import MPI


class TestBindings(TestCase):
    """
    Test suite to check correct behaviour of python bindings.
    """

    def test_constructor(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        self.assertTrue(True)

    def test_constructor_custom_mpi_comm(self):
        participant = precice.Participant(
            "test", "dummy.xml", 0, 1, MPI.COMM_WORLD)
        self.assertTrue(True)

    def test_version(self):
        precice.__version__

    def test_get_mesh_dimensions(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        # TODO: it would be nice to be able to mock the output of the interface
        # directly in the test, not in test/Participant.hpp
        fake_mesh_dimension = 3  # compare to test/Participant.hpp, fake_mesh_dimension
        # TODO: it would be nice to be able to mock the output of the interface
        # directly in the test, not in test/Participant.hpp
        self.assertEqual(fake_mesh_dimension, participant.get_mesh_dimensions("dummy"))

    def test_get_data_dimensions(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_scalar_data_dimension = 1  # compare to test/Participant.hpp, fake_scalar_data_dimension
        self.assertEqual(fake_scalar_data_dimension, participant.get_data_dimensions("dummy", "FakeScalarData"))
        fake_vector_data_dimension = 3  # compare to test/Participant.hpp, fake_vector_data_dimension
        self.assertEqual(fake_vector_data_dimension, participant.get_data_dimensions("dummy", "FakeVectorData"))

    def test_requires_mesh_connectivity_for(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_bool = 0  # compare to output in test/SolverInterface.cpp
        fake_mesh_name = "FakeMesh"
        self.assertEqual(fake_bool, participant.requires_mesh_connectivity_for(fake_mesh_name))

    def test_set_mesh_vertices(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 0  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.zeros((n_fake_vertices, fake_dimension))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = list(list(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        positions = []
        n_fake_vertices = 0
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = tuple(tuple(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_empty_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        positions = ()
        n_fake_vertices = 0
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertices_mixed(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        positions = np.random.rand(n_fake_vertices, fake_dimension)
        positions = list(tuple(positions[i, j] for j in range(
            positions.shape[1])) for i in range(positions.shape[0]))
        expected_output = np.array(range(n_fake_vertices))
        actual_output = participant.set_mesh_vertices(fake_mesh_name, positions)
        self.assertTrue(np.array_equal(expected_output, actual_output))

    def test_set_mesh_vertex(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        position = np.random.rand(fake_dimension)
        vertex_id = participant.set_mesh_vertex(fake_mesh_name, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_empty(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 0  # compare to test/SolverInterface.cpp, fake_dimensions
        position = np.random.rand(fake_dimension)
        vertex_id = participant.set_mesh_vertex(fake_mesh_name, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        position = list(np.random.rand(fake_dimension))
        vertex_id = participant.set_mesh_vertex(fake_mesh_name, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_empty_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        position = []
        vertex_id = participant.set_mesh_vertex(fake_mesh_name, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        position = tuple(np.random.rand(fake_dimension))
        vertex_id = participant.set_mesh_vertex(fake_mesh_name, position)
        self.assertTrue(0 == vertex_id)

    def test_set_mesh_vertex_empty_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        position = ()
        vertex_id = participant.set_mesh_vertex(fake_mesh_name, position)
        self.assertTrue(0 == vertex_id)

    def test_get_mesh_vertex_size(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        n_vertices = participant.get_mesh_vertex_size(fake_mesh_name)
        self.assertTrue(n_fake_vertices == n_vertices)

    def test_read_write_block_scalar_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([3, 7, 8], dtype=np.double)
        participant.write_data("FakeMesh", "FakeScalarData", np.array([0, 1, 2]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", np.array([0, 1, 2]), dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_scalar_data_single_float(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = 8
        with self.assertRaises(TypeError):
            participant.write_data("FakeMesh", "FakeScalarData", 1, write_data)
        with self.assertRaises(TypeError):
            participant.read_data("FakeMesh", "FakeScalarData", 1)

    def test_read_write_block_scalar_data_empty(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([])
        participant.write_data("FakeMesh", "FakeScalarData", [], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", [], dt)
        self.assertTrue(len(read_data) == 0)

    def test_read_write_block_scalar_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(3, 3)
        write_data = dummy_array[:, 1]
        assert (write_data.flags["C_CONTIGUOUS"] is False)
        participant.write_data("FakeMesh", "FakeScalarData", np.array([0, 1, 2]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", np.array([0, 1, 2]), dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_scalar_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [3]
        participant.write_data("FakeMesh", "FakeScalarData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", [0], dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([[3, 7, 8],
                               [7, 6, 5]], dtype=np.double)
        participant.write_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array([0, 1]), dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_empty(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([])
        participant.write_data("FakeMesh", "FakeVectorData", [], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [], dt)
        self.assertTrue(len(read_data) == 0)

    def test_read_write_block_vector_data_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [[3, 7, 8], [7, 6, 5]]
        participant.write_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array([0, 1]), dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = ((3, 7, 8), (7, 6, 5))
        participant.write_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array([0, 1]), dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_mixed(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [(3, 7, 8), (7, 6, 5)]
        participant.write_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array([0, 1]), dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_block_vector_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        size = 6
        dummy_array = np.random.rand(size, 5)
        write_data = dummy_array[:, 1:4]
        assert (write_data.flags["C_CONTIGUOUS"] is False)
        vertex_ids = np.arange(size)
        participant.write_data("FakeMesh", "FakeVectorData", vertex_ids, write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", vertex_ids, dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([[0, 1, 2]], dtype=np.double)
        participant.write_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [0], dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [[0, 1, 2]]
        participant.write_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [0], dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [(1, 2, 3)]
        participant.write_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [0], dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_read_write_vector_data_non_contiguous(self):
        """
        Tests behaviour of solver interface, if a non contiguous array is passed to the interface.

        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(3, 3)
        write_data = dummy_array[:, 1]
        assert (write_data.flags["C_CONTIGUOUS"] is False)
        write_data = [write_data]
        participant.write_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [0], dt)
        self.assertTrue(np.array_equal(write_data, read_data))

    def test_get_version_information(self):
        version_info = precice.get_version_information()
        fake_version_info = b"dummy"  # compare to test/SolverInterface.cpp
        self.assertEqual(version_info, fake_version_info)

    def test_set_mesh_access_region(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        fake_bounding_box = np.arange(fake_dimension * 2)
        participant.set_mesh_access_region(fake_mesh_name, fake_bounding_box)

    def test_get_mesh_vertex_ids_and_coordinates(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_mesh_name = "FakeMesh"  # compare to test/SolverInterface.cpp, fake_mesh_name
        n_fake_vertices = 3  # compare to test/SolverInterface.cpp, n_fake_vertices
        fake_dimension = 3  # compare to test/SolverInterface.cpp, fake_dimensions
        vertex_ids = np.arange(n_fake_vertices)
        coordinates = np.zeros((n_fake_vertices, fake_dimension))
        for i in range(n_fake_vertices):
            coordinates[i, 0] = i * fake_dimension
            coordinates[i, 1] = i * fake_dimension + 1
            coordinates[i, 2] = i * fake_dimension + 2
        fake_ids, fake_coordinates = participant.get_mesh_vertex_ids_and_coordinates(fake_mesh_name)
        self.assertTrue(np.array_equal(fake_ids, vertex_ids))
        self.assertTrue(np.array_equal(fake_coordinates, coordinates))

    def test_requires_gradient_data_for(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_bool = 0  # compare to output in test/SolverInterface.cpp
        fake_mesh_name = "FakeMesh"
        fake_data_name = "FakeName"
        self.assertEqual(fake_bool, participant.requires_gradient_data_for(fake_mesh_name, fake_data_name))

    def test_write_block_scalar_gradient_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([[0, 1, 2], [6, 7, 8], [9, 10, 11]], dtype=np.double)
        participant.write_gradient_data("FakeMesh", "FakeScalarData", np.array([0, 1, 2]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", np.array(range(9)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_block_scalar_gradient_data_single_float(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_dimension = 3
        n_fake_vertices = 1
        vertex_ids = np.arange(n_fake_vertices)
        write_data = np.random.rand(n_fake_vertices, fake_dimension)
        participant.write_gradient_data("FakeMesh", "FakeScalarData", vertex_ids, write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", np.arange(n_fake_vertices * fake_dimension), dt)
        self.assertTrue(np.array_equal(write_data.flatten(), read_data))

    def test_write_block_scalar_gradient_data_empty(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([])
        participant.write_gradient_data("FakeMesh", "FakeScalarData", [], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", [], dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_block_scalar_gradient_data_non_contiguous(self):
        """
        Tests behavior of solver interface, if a non contiguous array is passed to the interface.
        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(3, 9)
        write_data = dummy_array[:, 3:6]
        assert write_data.flags["C_CONTIGUOUS"] is False
        participant.write_gradient_data("FakeMesh", "FakeScalarData", np.array([0, 1, 2]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeScalarData", np.array(range(9)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_scalar_gradient_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_dimension = 3
        write_data = [np.random.rand(fake_dimension)]
        participant.write_gradient_data("FakeMesh", "FakeScalarData", [0], write_data)
        dt = 1
        # Gradient data is essential vector data, hence the appropriate data name is used here
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [0], dt)
        self.assertTrue(np.array_equiv(write_data, read_data))

    def test_write_block_vector_gradient_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        fake_dimension = 3
        n_fake_vertices = 4
        vertex_ids = np.arange(n_fake_vertices)
        write_data = np.random.rand(n_fake_vertices, fake_dimension * fake_dimension)
        participant.write_gradient_data("FakeMesh", "FakeVectorData", vertex_ids, write_data)
        dt = 1
        read_data = participant.read_data(
            "FakeMesh", "FakeVectorData", np.array(range(n_fake_vertices * fake_dimension)), dt)
        self.assertTrue(np.array_equiv(write_data.flatten(), read_data.flatten()))

    def test_write_block_vector_gradient_data_empty(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = np.array([])
        participant.write_gradient_data("FakeMesh", "FakeVectorData", [], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", [], dt)
        self.assertTrue(len(read_data) == 0)

    def test_write_block_vector_gradient_data_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [[3.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0], [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 6.0, 5.0]]
        participant.write_gradient_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(6)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_block_vector_gradient_data_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = ((1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 3.0, 7.0, 8.0), (1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 6.0, 5.0))
        participant.write_gradient_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(6)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_block_vector_gradient_data_mixed(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 3.0, 7.0, 8.0), (4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 7.0, 6.0, 5.0)]
        participant.write_gradient_data("FakeMesh", "FakeVectorData", np.array([0, 1]), write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(6)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_block_vector_gradient_data_non_contiguous(self):
        """
        Tests behavior of solver interface, if a non contiguous array is passed to the interface.
        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(3, 15)
        write_data = dummy_array[:, 2:11]
        assert write_data.flags["C_CONTIGUOUS"] is False
        vertex_ids = np.arange(3)
        participant.write_gradient_data("FakeMesh", "FakeVectorData", vertex_ids, write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(9)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_vector_gradient_data(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [np.arange(0, 9, dtype=np.double)]
        participant.write_gradient_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(3)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_vector_gradient_data_list(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]]
        participant.write_gradient_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(3)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_vector_gradient_data_tuple(self):
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        write_data = [(1.0, 2.0, 3.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0)]
        participant.write_gradient_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(3)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))

    def test_write_vector_gradient_data_non_contiguous(self):
        """
        Tests behavior of solver interface, if a non contiguous array is passed to the interface.
        Note: Check whether np.ndarray is contiguous via np.ndarray.flags.
        """
        participant = precice.Participant("test", "dummy.xml", 0, 1)
        dummy_array = np.random.rand(9, 3)
        write_data = dummy_array[:, 1]
        assert write_data.flags["C_CONTIGUOUS"] is False
        write_data = [write_data]
        participant.write_gradient_data("FakeMesh", "FakeVectorData", [0], write_data)
        dt = 1
        read_data = participant.read_data("FakeMesh", "FakeVectorData", np.array(range(3)), dt)
        self.assertTrue(np.array_equiv(np.array(write_data).flatten(), read_data.flatten()))
