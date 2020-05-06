from __future__ import division

import argparse
import numpy as np
import precice

parser = argparse.ArgumentParser()
parser.add_argument("configurationFileName", help="Name of the xml config file.", type=str)
parser.add_argument("participantName", help="Name of the solver.", type=str)
parser.add_argument("meshName", help="Name of the mesh.", type=str)

try:
    args = parser.parse_args()
except SystemExit:
    print("")
    print("Usage: python ./solverdummy precice-config participant-name mesh-name")    
    quit()

configuration_file_name = args.configurationFileName
participant_name = args.participantName
mesh_name = args.meshName
if (participant_name == 'SolverOne'):
  DataWrite_Name='Forces'
  DataRead_Name='Velocities'

if (participant_name == 'SolverTwo'):
  DataRead_Name='Forces'
  DataWrite_Name='Velocities'

n = 3               #Number of vertices

solver_process_index = 0
solver_process_size = 1

interface = precice.Interface(participant_name, configuration_file_name, solver_process_index, solver_process_size)
    
mesh_id = interface.get_mesh_id(mesh_name)

dimensions = interface.get_dimensions()
vertices = np.zeros((n, dimensions))
readData = np.zeros((n, dimensions))
writeData = np.zeros((n, dimensions))

for x in range(0,n):
    for y in range(0,dimensions):
        vertices[x,y] = x
        readData[x,y] = x 
        writeData[x,y] = x

data_indices = interface.set_mesh_vertices(mesh_id, vertices)

DataRead_ID = interface.get_data_id(DataRead_Name,mesh_id)
DataWrite_ID = interface.get_data_id(DataWrite_Name,mesh_id)

dt = interface.initialize()
    
while interface.is_coupling_ongoing():
   
    if interface.is_action_required(precice.action_write_iteration_checkpoint()):
        interface.write_block_vector_data(DataWrite_ID, data_indices,writeData)  
        print("DUMMY: Writing iteration checkpoint")
        interface.mark_action_fulfilled(precice.action_write_iteration_checkpoint())
    
    dt = interface.advance(dt)
    
    if interface.is_action_required(precice.action_read_iteration_checkpoint()):
        readData = interface.read_block_vector_data(DataRead_ID, data_indices)      
        print("DUMMY: Reading iteration checkpoint")
        interface.mark_action_fulfilled(precice.action_read_iteration_checkpoint())
    else:
        print("DUMMY: Advancing in time")

    writeData = readData + 1
    print("DUMMY: writeData = ", writeData)

    
interface.finalize()
print("DUMMY: Closing python solver dummy...")

