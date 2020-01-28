Migration Guide for Python language bindings for preCICE version 2.0
------------------------------------

# Steps to move from old Python API to the new API

### 1. Python language bindings moved to a new repository in the preCICE Project

Previously, the Python language bindings were part of the repository [`precice/precice`](https://github.com/precice/precice). 
The bindings have now been moved to the independent repository [`precice/python-bindings`](https://github.com/precice/python-bindings).

The installation procedure is the same as before. Please refer to the [README](https://github.com/precice/python-bindings/blob/develop/README.md).

### 2. New initialization of `Interface`

The initialization of the `Interface` object now initializes the solver and also configures it using the configuration
file provided by the user.

**Old:** Before preCICE Version 2 you had to call:
```
interface = precice.Interface(solverName, processRank, processSize)
interface.configure(configFileName)
```

**New:** The two commands have now been combined into a single one:
```
interface = precice.Interface(solverName, configFileName, processRank, processSize)
```

### 3. Reduced number of inputs arguments for API calls

Unlike the old bindings, API calls now do not need the array size to be passed as an argument anymore. The bindings directly take the size of the array that you are providing.

For example let us consider the call `write_block_vector_data`:

**Old:** The previous call was:
```
interface.write_block_vector_data(writeDataID, writeDataSize, vertexIDs, writeDataArray)
```

**New:** The new function call is:
```
interface.write_block_vector_data(writeDataID, vertexIDs, writeDataArray)
```
The same change is applied for all other calls which work with arrays of data.

### 4. API functions use a return value, if appropriate

In older versions of the python bindings arrays were modified by the API in a call-by-reference fashion. This means a pointer to the array was passed to the API as a function argument. This approach was changed and the API functions now directly return the an array.

For example let us consider the interface function `set_mesh_vertices`. `set_mesh_vertices` is used to register vertices for a mesh and it returns an array of `vertexIDs`.

**Old:** The old signature of this function was:
```
vertexIDs = np.zeros(numberofVertices)
interface.set_mesh_vertices(meshID, numberofVertices, grid, vertexIDs)
```
Note that `vertexIDs` is passed as an argument to the function.

**New:** This has now been changed to:
```
vertexIDs = interface.set_mesh_vertices(meshID, grid)
```
Here, `vertexIDs` is directly returned by `set_mesh_vertices`.

The same change has been applied to the functions `read_block_scalar_data` and `read_block_vector_data`.

### 5. Consequently use numpy arrays as data structure

We consequently use numpy arrays for storing array data (multidimensional lists are still accepted). As an example, the `N` coupling mesh vertices of a mesh in `D` dimensions are represented as `grid = np.zeros([N, D])`. Previous versions of the bindings used either `grid = np.zeros([N, D])` (transposed version) or `grid = np.zeros(N*D)`. The same rule applies for data written and read in `write_block_vector_data` and `read_block_vector_data`.
