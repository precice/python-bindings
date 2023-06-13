from __future__ import division

import argparse
import numpy as np
import precice

parser = argparse.ArgumentParser()
parser.add_argument("configurationFileName",
                    help="Name of the xml config file.", type=str)
parser.add_argument("participantName", help="Name of the solver.", type=str)

try:
    args = parser.parse_args()
except SystemExit:
    print("")
    print("Usage: python ./solverdummy precice-config participant-name")
    quit()

configuration_file_name = args.configurationFileName
participant_name = args.participantName

if participant_name == 'SolverOne':
    write_data_name = 'Data-One'
    read_data_name = 'Data-Two'
    mesh_name = 'SolverOne-Mesh'

if participant_name == 'SolverTwo':
    read_data_name = 'Data-One'
    write_data_name = 'Data-Two'
    mesh_name = 'SolverTwo-Mesh'

num_vertices = 3  # Number of vertices

solver_process_index = 0
solver_process_size = 1

interface = precice.Interface(participant_name, configuration_file_name,
                              solver_process_index, solver_process_size)

assert (interface.requires_mesh_connectivity_for(mesh_name) is False)

dimensions = interface.get_dimensions()

vertices = np.zeros((num_vertices, dimensions))
read_data = np.zeros((num_vertices, dimensions))
write_data = np.zeros((num_vertices, dimensions))

for x in range(num_vertices):
    for y in range(0, dimensions):
        vertices[x, y] = x
        read_data[x, y] = x
        write_data[x, y] = x

vertex_ids = interface.set_mesh_vertices(mesh_name, vertices)

dt = interface.initialize()

while interface.is_coupling_ongoing():
    if interface.requires_writing_checkpoint():
        print("DUMMY: Writing iteration checkpoint")

    read_data = interface.read_block_vector_data(mesh_name, read_data_name, vertex_ids)

    write_data = read_data + 1

    interface.write_block_vector_data(mesh_name, write_data_name, vertex_ids, write_data)

    print("DUMMY: Advancing in time")
    dt = interface.advance(dt)

    if interface.requires_reading_checkpoint():
        print("DUMMY: Reading iteration checkpoint")

interface.finalize()
print("DUMMY: Closing python solver dummy...")
