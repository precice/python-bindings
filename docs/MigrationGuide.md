Migration Guide for Python language bindings for preCICE version 2.0
------------------------------------

# Steps to move from old Python API to the new API

## 1. Solver Interface initialization call is changed

The solver interface initialization call now initializes the solver and also configures it using the configuration
file provided by the user.
The previous calls were:
```
interface = precice.Interface(solverName, processRank, processSize)
interface.configure(configFileName)
```
The calls have now been combined to:
```
interface = precice.Interface(solverName, configFileName, processRank, processSize)
```

## 2. Array updation is done by returning the appropriate array rather than implicit updating of function argument

In the old adapter the array of values which was generated or updated by a API function was passed as a function argument.
This is now changed and the API function returns the appropriate which is intended to be computed or updated.
For example let us consider the interface function `set_mesh_vertices`:
The old use of this function to generate coupling mesh vertices (vertexIDs) was:
```
interface.set_mesh_vertices(meshID, numberofVertices, grid, vertexIDs)
```
This has now been changed to:
```
vertexIDs = interface.set_mesh_vertices(meshID, grid)
```
The same change has been done in API calls to read data from preCICE. 
The previous call to read data was:
```
interface.read_block_scalar_data(readDataID, readDataSize, vertexIDs, readDataArray)
```
The new call is:
```
readDataArray = interface.read_block_scalar_data(readDataID, vertexIDs)
```

## 3. Reduced number of inputs arguments for API calls

Unlike the old bindings, API calls now do not need the array size to be passed as an argument anymore. 
For example let us consider the call `set_mesh_vertices`.
The previous call was:
```
interface.set_mesh_vertices(meshID, numberofVertices, grid, vertexIDs)
```
This has now been changed to:
```
vertexIDs = interface.set_mesh_vertices(meshID, grid)
```
The same change can be seen for all other calls which work with arrays of data. For example the call
`write_block_vector_data` is changed as follows:
The previous call was:
```
interface.write_block_vector_data(writeDataID, writeDataSize, vertexIDs, writeDataArray)
```
The new function call is:
```
interface.write_block_vector_data(writeDataID, vertexIDs, writeDataArray)
```
Analogously this same change is done for function call `write_block_scalar_data` and all other relevant functions.

## 4. 

