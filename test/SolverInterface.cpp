#include "precice/SolverInterface.hpp"
#include "precice/Tooling.hpp"
#include <iostream>
#include <numeric>
#include <cassert>
#include <vector>
#include <string_view>

std::string fake_version;
std::vector<double> fake_read_write_buffer;
int fake_dimensions;
std::vector<int> fake_ids;
int n_fake_vertices;
std::string fake_mesh_name;
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
  std::string_view participantName,
  std::string_view configurationFileName,
  int                solverProcessIndex,
  int                solverProcessSize )
{
  fake_version = "dummy";
  fake_read_write_buffer = std::vector<double>();
  fake_dimensions = 3;
  fake_data_id = 15;
  fake_mesh_name = "FakeMesh";
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
    std::string_view participantName,
    std::string_view configurationFileName,
    int                solverProcessIndex,
    int                solverProcessSize,
    void *             communicator)
{
  fake_version = "dummy";
  fake_read_write_buffer = std::vector<double>();
  fake_dimensions = 3;
  fake_mesh_id = 0;
  fake_data_id = 15;
  fake_mesh_name = "FakeMesh";
  fake_data_name = "FakeData";
  n_fake_vertices = 3;
  fake_ids.resize(n_fake_vertices);
  std::iota(fake_ids.begin(), fake_ids.end(), 0);
  fake_bounding_box.resize(fake_dimensions*2);
  std::iota(fake_bounding_box.begin(), fake_bounding_box.end(), 0);
}

SolverInterface::~SolverInterface() = default;

double SolverInterface:: initialize()
{
  return -1;
}

double SolverInterface:: advance
(
  double computedTimestepLength )
{
  return -1;
}

void SolverInterface:: finalize()
{}

int SolverInterface:: getDimensions() const
{
  return fake_dimensions;
}

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
  std::string_view meshName ) const
{
  return 0;
}

bool SolverInterface:: requiresMeshConnectivityFor
(
  std::string_view meshName) const
{
  return 0;
}

bool SolverInterface::requiresGradientDataFor
(
  std::string_view meshName,
  std::string_view dataName) const
{
  return 0;
}

bool SolverInterface:: hasData
(
  std::string_view dataName,
  std::string_view meshName) const
{
  return 0;
}

int SolverInterface:: setMeshVertex
(
  std::string_view meshName,
  const double* position )
{
  return 0;
}

int SolverInterface:: getMeshVertexSize
(
  std::string_view meshName) const
{
  return n_fake_vertices;
}

void SolverInterface:: setMeshVertices
(
  std::string_view meshName,
  int           size,
  const double* positions,
  int*          ids )
{
  assert (size == fake_ids.size());
  std::copy(fake_ids.begin(), fake_ids.end(), ids);
}

void SolverInterface:: setMeshEdge
(
  std::string_view meshName,
  int firstVertexID,
  int secondVertexID )
{}

void SolverInterface::setMeshEdges(
    std::string_view meshName,
    int              size,
    const int *      vertices)
{}

void SolverInterface:: setMeshTriangle
(
  std::string_view meshName,
  int firstVertexID,
  int secondVertexID,
  int thirdVertexID )
{}

void SolverInterface:: setMeshTriangles
(
  std::string_view meshName,
  int size,
  const int * vertices )
{}

void SolverInterface:: setMeshQuad
(
  std::string_view meshName,
  int firstVertexID,
  int secondVertexID,
  int thirdVertexID,
  int fourthVertexID )
{}

void SolverInterface:: setMeshQuads
(
  std::string_view meshName,
  int              size,
  const int *      vertices)
{}

void SolverInterface::setMeshTetrahedron(
    std::string_view meshName,
    int              firstVertexID,
    int              secondVertexID,
    int              thirdVertexID,
    int              fourthVertexID)
{}

void SolverInterface::setMeshTetrahedra(
    std::string_view meshName,
    int              size,
    const int *      vertices)
{}

void SolverInterface:: writeBlockVectorData
(
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
  int    valueIndex,
  double value )
{
    fake_read_write_buffer.clear();
    fake_read_write_buffer.push_back(value);
}

void SolverInterface::writeBlockVectorGradientData(
    std::string_view meshName,
    std::string_view dataName,
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
    std::string_view meshName,
    std::string_view dataName,
    int           valueIndex,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}
void SolverInterface::writeBlockScalarGradientData(
    std::string_view meshName,
    std::string_view dataName,
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
    std::string_view meshName,
    std::string_view dataName,
    int           valueIndex,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < this->getDimensions() * this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}

void SolverInterface:: readBlockVectorData
(
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
  int     valueIndex,
  double* value ) const
{
  for(int i = 0; i < this->getDimensions(); i++){
      value[i] = fake_read_write_buffer[i];
    }
}

void SolverInterface:: readVectorData
(
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
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
  std::string_view meshName,
  std::string_view dataName,
  int     valueIndex,
  double& value ) const
{
    value = fake_read_write_buffer[0];
}

void SolverInterface:: readScalarData
(
  std::string_view meshName,
  std::string_view dataName,
  int     valueIndex,
  double  relativeReadTime,
  double& value ) const
{
    value = fake_read_write_buffer[0];
}

void SolverInterface:: setMeshAccessRegion
(
  std::string_view meshName,
  const double* boundingBox ) const
{
    assert(meshName == fake_mesh_name);

    for(std::size_t i = 0; i < fake_bounding_box.size(); i++){
        assert(boundingBox[i] == fake_bounding_box[i]);
    }
}

void SolverInterface:: getMeshVerticesAndIDs
(
  std::string_view meshName,
  const int size,
  int* valueIndices,
  double* coordinates ) const
{
    assert(meshName == fake_mesh_name);
    assert(size == fake_ids.size());

    for(std::size_t i = 0; i < fake_ids.size(); i++){
        valueIndices[i] = fake_ids[i];
    }
    for(std::size_t i = 0; i < fake_coordinates.size(); i++){
        coordinates[i] = fake_coordinates[i];
    }
}

std::string getVersionInformation()
{
  return fake_version;
}

} // namespace precice