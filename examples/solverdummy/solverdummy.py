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

participant = precice.Participant(participant_name, configuration_file_name,
                                  solver_process_index, solver_process_size)

assert (participant.requires_mesh_connectivity_for(mesh_name) is False)

vertices = np.zeros((num_vertices, participant.get_mesh_dimensions(mesh_name)))
read_data = np.zeros((num_vertices, participant.get_data_dimensions(mesh_name, read_data_name)))
write_data = np.zeros((num_vertices, participant.get_data_dimensions(mesh_name, write_data_name)))

for x in range(num_vertices):
    for y in range(participant.get_mesh_dimensions(mesh_name)):
        vertices[x, y] = x

    for y in range(participant.get_data_dimensions(mesh_name, read_data_name)):
        read_data[x, y] = x

    for y in range(participant.get_data_dimensions(mesh_name, write_data_name)):
        write_data[x, y] = x

vertex_ids = participant.set_mesh_vertices(mesh_name, vertices)

participant.initialize()

while participant.is_coupling_ongoing():
    if participant.requires_writing_checkpoint():
        print("DUMMY: Writing iteration checkpoint")

    dt = participant.get_max_time_step_size()
    read_data = participant.read_data(mesh_name, read_data_name, vertex_ids, dt)

    write_data = read_data + 1

    participant.write_data(mesh_name, write_data_name, vertex_ids, write_data)

    print("DUMMY: Advancing in time")
    dt = participant.get_max_time_step_size()
    participant.advance(dt)

    if participant.requires_reading_checkpoint():
        print("DUMMY: Reading iteration checkpoint")

participant.finalize()
print("DUMMY: Closing python solver dummy...")
