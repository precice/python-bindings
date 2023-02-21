#include "precice/SolverInterface.hpp"
#include <iostream>
#include <numeric>
#include <cassert>

std::vector<double> fake_read_write_buffer;
int fake_dimensions;
int fake_mesh_id;
std::vector<int> fake_ids;
int n_fake_vertices;
std::string fake_data_name;
int fake_data_id;
std::vector<double> fake_bounding_box;
std::vector<double> fake_coordinates;

namespace precice {

namespace impl{
class SolverInterfaceImpl{};
}

SolverInterface:: SolverInterface
(
  const std::string& participantName,
  const std::string& configurationFileName,
  int                solverProcessIndex,
  int                solverProcessSize )
{
  fake_read_write_buffer = std::vector<double>();
  fake_dimensions = 3;
  fake_mesh_id = 0;
  fake_data_id = 15;
  fake_data_name = "FakeData";
  n_fake_vertices = 3;
  fake_ids.resize(n_fake_vertices);
  std::iota(fake_ids.begin(), fake_ids.end(), 0);
  fake_bounding_box.resize(fake_dimensions*2);
  std::iota(fake_bounding_box.begin(), fake_bounding_box.end(), 0);
  fake_coordinates.resize(n_fake_vertices*fake_dimensions);
  std::iota(fake_coordinates.begin(), fake_coordinates.end(), 0);
}

SolverInterface::SolverInterface(
    const std::string& participantName,
    const std::string& configurationFileName,
    int                solverProcessIndex,
    int                solverProcessSize,
    void *             communicator)
{
  fake_read_write_buffer = std::vector<double>();
  fake_dimensions = 3;
  fake_mesh_id = 0;
  fake_data_id = 15;
  fake_data_name = "FakeData";
  n_fake_vertices = 3;
  fake_ids.resize(n_fake_vertices);
  std::iota(fake_ids.begin(), fake_ids.end(), 0);
  fake_bounding_box.resize(fake_dimensions*2);
  std::iota(fake_bounding_box.begin(), fake_bounding_box.end(), 0);
}

SolverInterface::~SolverInterface() = default;

double SolverInterface:: initialize(){return -1;}

double SolverInterface:: advance
(
  double computedTimestepLength )
{return -1;}

void SolverInterface:: finalize()
{}

int SolverInterface:: getDimensions() const
{return fake_dimensions;}

bool SolverInterface:: isCouplingOngoing() const
{
  return 0;
}

bool SolverInterface:: isTimeWindowComplete() const
{
  return 0;
}

bool SolverInterface:: requiresInitialData()
{
  return 0;
}

bool SolverInterface:: requiresReadingCheckpoint()
{
  return 0;
}

bool SolverInterface:: requiresWritingCheckpoint()
{
  return 0;
}

bool SolverInterface:: hasMesh
(
  const std::string& meshName ) const
{
  return 0;
}

int SolverInterface:: getMeshID
(
  const std::string& meshName ) const
{
  return fake_mesh_id;
}

std::set<int> SolverInterface:: getMeshIDs() const
{
  return std::set<int>();
}

bool SolverInterface:: hasData
(
  const std::string& dataName, int meshID ) const
{
  return 0;
}

int SolverInterface:: getDataID
(
  const std::string& dataName, int meshID ) const
{
  if(meshID == fake_mesh_id && dataName == fake_data_name)
  {
    return fake_data_id;
  }
  else
  {
    return -1;
  }
}

bool SolverInterface:: requiresMeshConnectivityFor(int meshID) const
{
  return 0;
}

int SolverInterface:: setMeshVertex
(
  int           meshID,
  const double* position )
{
  return 0;
}

int SolverInterface:: getMeshVertexSize
(
  int meshID) const
{
  return n_fake_vertices;
}

void SolverInterface:: setMeshVertices
(
  int           meshID,
  int           size,
  const double* positions,
  int*          ids )
{
  assert (size == fake_ids.size());
  std::copy(fake_ids.begin(), fake_ids.end(), ids);
}

void SolverInterface:: setMeshEdge
(
  int meshID,
  int firstVertexID,
  int secondVertexID )
{}

void SolverInterface:: setMeshEdges
(
  int meshID,
  int size,
  const int* vertices )
{}

void SolverInterface:: setMeshTriangle
(
  int meshID,
  int firstVertexID,
  int secondVertexID,
  int thirdVertexID )
{}

void SolverInterface:: setMeshTriangles
(
  int meshID,
  int size,
  const int* vertices )
{}

void SolverInterface:: setMeshQuad
(
  int meshID,
  int firstVertexID,
  int secondVertexID,
  int thirdVertexID,
  int fourthVertexID )
{}

void SolverInterface:: setMeshQuads
(
  int meshID,
  int size,
  const int* vertices )
{}

void SolverInterface:: writeBlockVectorData
(
  int     dataID,
  int     size,
  const int*    valueIndices,
  const double* values )
{
  fake_read_write_buffer.clear();
  for(int i = 0; i < size * this->getDimensions(); i++){
      fake_read_write_buffer.push_back(values[i]);
    }
}

void SolverInterface:: writeVectorData
(
  int           dataID,
  int           valueIndex,
  const double* value )
{
  fake_read_write_buffer.clear();
  for(int i = 0; i < this->getDimensions(); i++){
      fake_read_write_buffer.push_back(value[i]);
    }
}

void SolverInterface:: writeBlockScalarData
(
  int           dataID,
  int           size,
  const int*    valueIndices,
  const double* values )
{
  fake_read_write_buffer.clear();
  for(int i = 0; i < size; i++){
      fake_read_write_buffer.push_back(values[i]);
    }
}

void SolverInterface:: writeScalarData
(
  int    dataID,
  int    valueIndex,
  double value )
{
    fake_read_write_buffer.clear();
    fake_read_write_buffer.push_back(value);
}

void SolverInterface:: readBlockVectorData
(
  int        dataID,
  int        size,
  const int* valueIndices,
  double*    values ) const
{
  for(int i = 0; i < size * this->getDimensions(); i++){
      values[i] = fake_read_write_buffer[i];
    }
}

void SolverInterface:: readBlockVectorData
(
  int        dataID,
  int        size,
  const int* valueIndices,
  double     relativeReadTime,
  double*    values ) const
{
  for(int i = 0; i < size * this->getDimensions(); i++){
      values[i] = fake_read_write_buffer[i];
    }
}

void SolverInterface:: readVectorData
(
  int     dataID,
  int     valueIndex,
  double* value ) const
{
  for(int i = 0; i < this->getDimensions(); i++){
      value[i] = fake_read_write_buffer[i];
    }
}

void SolverInterface:: readVectorData
(
  int     dataID,
  int     valueIndex,
  double  relativeReadTime,
  double* value ) const
{
  for(int i = 0; i < this->getDimensions(); i++){
      value[i] = fake_read_write_buffer[i];
    }
}

void SolverInterface:: readBlockScalarData
(
  int        dataID,
  int        size,
  const int* valueIndices,
  double*    values ) const
{
  for(int i = 0; i < size; i++){
      values[i] = fake_read_write_buffer[i];
    }
}

void SolverInterface:: readBlockScalarData
(
  int        dataID,
  int        size,
  const int* valueIndices,
  double     relativeReadTime,
  double*    values ) const
{
  for(int i = 0; i < size; i++){
      values[i] = fake_read_write_buffer[i];
  }
}

void SolverInterface:: readScalarData
(
  int     dataID,
  int     valueIndex,
  double& value ) const
{
    value = fake_read_write_buffer[0];
}

void SolverInterface:: readScalarData
(
  int     dataID,
  int     valueIndex,
  double  relativeReadTime,
  double& value ) const
{
    value = fake_read_write_buffer[0];
}

void SolverInterface:: setMeshAccessRegion
(
  const int meshID,
  const double* boundingBox ) const
{
    assert(meshID == fake_mesh_id);

    for(int i = 0; i < fake_bounding_box.size(); i++){
        assert(boundingBox[i] == fake_bounding_box[i]);
    }
}

void SolverInterface:: getMeshVerticesAndIDs
(
  const int meshID,
  const int size,
  int* valueIndices,
  double* coordinates ) const
{
    assert(meshID == fake_mesh_id);
    assert(size == fake_ids.size());

    for(int i = 0; i < fake_ids.size(); i++){
        valueIndices[i] = fake_ids[i];
    }
    for(int i = 0; i < fake_coordinates.size(); i++){
        coordinates[i] = fake_coordinates[i];
    }
}

bool SolverInterface::requiresGradientDataFor(int dataID) const
{
  return 0;
}

void SolverInterface::writeBlockVectorGradientData(
    int           dataID,
    int           size,
    const int    *valueIndices,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < size * this->getDimensions() * this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}

void SolverInterface::writeScalarGradientData(
    int           dataID,
    int           valueIndex,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}
void SolverInterface::writeBlockScalarGradientData(
    int           dataID,
    int           size,
    const int    *valueIndices,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < size * this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}

void SolverInterface::writeVectorGradientData(
    int           dataID,
    int           valueIndex,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < this->getDimensions() * this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}

std::string getVersionInformation()
{
    std::string dummy ("dummy");
    return dummy;
}

} // namespace precice