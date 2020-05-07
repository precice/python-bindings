from __future__ import division

import argparse
import numpy as np
import precice

parser = argparse.ArgumentParser()
parser.add_argument("configurationFileName", help="Name of the xml config file.", type=str)
parser.add_argument("participantName", help="Name of the solver.", type=str)
parser.add_argument("meshName", help="Name of the mesh.", type=str)
args = None

try:
    args = parser.parse_args()
except SystemExit:
    print("")
    print("Usage: python ./solverdummy precice-config participant-name mesh-name")    
    quit()

configuration_file_name = args.configurationFileName
participant_name = args.participantName
mesh_name = args.meshName

write_data_name, read_data_name = None, None

if participant_name == 'SolverOne':
    write_data_name = 'Forces'
    read_data_name = 'Velocities'

if participant_name == 'SolverTwo':
    read_data_name = 'Forces'
    write_data_name = 'Velocities'

n = 3  # Number of vertices

solver_process_index = 0
solver_process_size = 1

interface = precice.Interface(participant_name, configuration_file_name, solver_process_index, solver_process_size)
    
mesh_id = interface.get_mesh_id(mesh_name)

dimensions = interface.get_dimensions()
vertices = np.zeros((n, dimensions))
readData = np.zeros((n, dimensions))
writeData = np.zeros((n, dimensions))

for x in range(0, n):
    for y in range(0, dimensions):
        vertices[x, y] = x
        readData[x, y] = x
        writeData[x, y] = x

vertex_ids = interface.set_mesh_vertices(mesh_id, vertices)

read_data_id = interface.get_data_id(read_data_name, mesh_id)
write_data_id = interface.get_data_id(write_data_name, mesh_id)

dt = interface.initialize()
    
while interface.is_coupling_ongoing():
   
    if interface.is_action_required(precice.action_write_iteration_checkpoint()):
        interface.write_block_vector_data(write_data_id, vertex_ids, writeData)
        print("DUMMY: Writing iteration checkpoint")
        interface.mark_action_fulfilled(precice.action_write_iteration_checkpoint())
    
    dt = interface.advance(dt)
    
    if interface.is_action_required(precice.action_read_iteration_checkpoint()):
        readData = interface.read_block_vector_data(read_data_id, vertex_ids)
        print("DUMMY: Reading iteration checkpoint")
        interface.mark_action_fulfilled(precice.action_read_iteration_checkpoint())
    else:
        print("DUMMY: Advancing in time")

    writeData = readData + 1
    print("DUMMY: writeData = ", writeData)

interface.finalize()
print("DUMMY: Closing python solver dummy...")
