Migration Guide for Python language bindings for preCICE version 2.0
------------------------------------

# Steps to move from old Python API to the new API

### 1. Python language bindings moved to a new repository in the preCICE Project

Previously the Python language bindings were part of the main preCICE repository. The bindings have now been
moved to an [independent repository](https://github.com/precice/python-bindings)

The installation procedure is same as mentioned in the [README](https://github.com/precice/python-bindings/blob/develop/README.md)

### 2. Solver Interface initialization call is changed

The solver interface initialization call now initializes the solver and also configures it using the configuration
file provided by the user.
The previous calls were:
```
interface = precice.Interface(solverName, processRank, processSize)
interface.configure(configFileName)
```
The calls have now been combined to one call:
```
interface = precice.Interface(solverName, configFileName, processRank, processSize)
```

### 3. Array updation is done by returning the updated array

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

### 4. Reduced number of inputs arguments for API calls

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

### 5. Formatting of Numpy arrays is changed

In the earlier bindings for a simulation in `D` dimensions, the Numpy array representing the coupling mesh having 
`N` vertices was structed as `grid = np.zeros([D, N+1])`.
The new structure now used is: `grid = np.zeros([N+1, D])`

In the earlier bindings it was the users responsibility to flatten a multi-dimensional array before passing it to
a API call. This is not not necessary as the API calls take care of this internally. For example let us consider
the call `set_mesh_vertices`:
The old call was:
```
interface.set_mesh_vertices(meshID, meshSize, grid.flatten('F'), vertexIDs)
```
This call is now modified to:
```
vertexIDs = interface.set_mesh_vertices(meshID, grid)
```

