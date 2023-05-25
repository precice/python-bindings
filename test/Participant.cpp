#include "precice/Participant.hpp"
#include "precice/Tooling.hpp"
#include <iostream>
#include <numeric>
#include <cassert>
#include <vector>

std::string fake_version;
std::vector<double> fake_read_write_buffer;
int fake_mesh_dimensions;
int fake_data_dimensions;
std::vector<int> fake_ids;
int n_fake_vertices;
std::string fake_mesh_name;
std::string fake_data_name;
int fake_data_id;
std::vector<double> fake_bounding_box;
std::vector<double> fake_coordinates;

namespace precice {

namespace impl{
class ParticipantImpl{};
}

Participant:: Participant
(
  precice::string_view participantName,
  precice::string_view configurationFileName,
  int                solverProcessIndex,
  int                solverProcessSize )
{
  fake_version = "dummy";
  fake_read_write_buffer = std::vector<double>();
  fake_mesh_dimensions = 3;
  fake_data_dimensions = 3;
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

Participant::Participant(
    precice::string_view participantName,
    precice::string_view configurationFileName,
    int                solverProcessIndex,
    int                solverProcessSize,
    void *             communicator)
{
  fake_version = "dummy";
  fake_read_write_buffer = std::vector<double>();
  fake_mesh_dimensions = 3;
  fake_data_dimensions = 3;
  fake_data_id = 15;
  fake_mesh_name = "FakeMesh";
  fake_data_name = "FakeData";
  n_fake_vertices = 3;
  fake_ids.resize(n_fake_vertices);
  std::iota(fake_ids.begin(), fake_ids.end(), 0);
  fake_bounding_box.resize(fake_dimensions*2);
  std::iota(fake_bounding_box.begin(), fake_bounding_box.end(), 0);
}

Participant::~Participant() = default;

double Participant:: initialize()
{
  return -1;
}

double Participant:: advance
(
  double computedTimestepLength )
{
  return -1;
}

void Participant:: finalize()
{}

int Participant:: getMeshDimensions
(
  precice::string_view meshName) const
{
  return fake_mesh_dimensions;
}

int Participant:: getDataDimensions
(
  precice::string_view meshName,
  precice::string_view dataName) const
{
  return fake_data_dimensions;
}

bool Participant:: isCouplingOngoing() const
{
  return 0;
}

bool Participant:: isTimeWindowComplete() const
{
  return 0;
}

double Participant:: getMaxTimeStepSize() const
{
  return 0.0;
}

bool Participant:: requiresInitialData()
{
  return 0;
}

bool Participant:: requiresReadingCheckpoint()
{
  return 0;
}

bool Participant:: requiresWritingCheckpoint()
{
  return 0;
}

bool Participant:: hasMesh
(
  precice::string_view meshName ) const
{
  return 0;
}

bool Participant:: requiresMeshConnectivityFor
(
  precice::string_view meshName) const
{
  return 0;
}

bool Participant:: hasData
(
  precice::string_view dataName,
  precice::string_view meshName) const
{
  return 0;
}

int Participant:: setMeshVertex
(
  precice::string_view meshName,
  const double* position )
{
  return 0;
}

int Participant:: getMeshVertexSize
(
  precice::string_view meshName) const
{
  return n_fake_vertices;
}

void Participant:: setMeshVertices
(
  precice::string_view meshName,
  const double* positions,
  int*          ids )
{
  assert (size == fake_ids.size());
  std::copy(fake_ids.begin(), fake_ids.end(), ids);
}

void Participant:: setMeshEdge
(
  precice::string_view meshName,
  int firstVertexID,
  int secondVertexID )
{}

void Participant::setMeshEdges(
    precice::string_view meshName,
    const int *      vertices)
{}

void Participant:: setMeshTriangle
(
  precice::string_view meshName,
  int firstVertexID,
  int secondVertexID,
  int thirdVertexID )
{}

void Participant:: setMeshTriangles
(
  precice::string_view meshName,
  const int * vertices )
{}

void Participant:: setMeshQuad
(
  precice::string_view meshName,
  int firstVertexID,
  int secondVertexID,
  int thirdVertexID,
  int fourthVertexID )
{}

void Participant:: setMeshQuads
(
  precice::string_view meshName,
  const int *      vertices)
{}

void Participant::setMeshTetrahedron
(
    precice::string_view meshName,
    int              firstVertexID,
    int              secondVertexID,
    int              thirdVertexID,
    int              fourthVertexID)
{}

void Participant::setMeshTetrahedra
(
    precice::string_view meshName,
    const int *      vertices)
{}

void Participant:: writeData
(
  precice::string_view meshName,
  precice::string_view dataName,
  const int*    vertices,
  double value )
{
    fake_read_write_buffer.clear();
    fake_read_write_buffer.push_back(value);
}

void Participant:: readData
(
  precice::string_view meshName,
  precice::string_view dataName,
  const int*     vertices,
  double  relativeReadTime,
  double& value ) const
{
    value = fake_read_write_buffer[0];
}

bool Participant::requiresGradientDataFor
(
  precice::string_view meshName,
  precice::string_view dataName) const
{
  return 0;
}

void Participant::writeGradientData(
    precice::string_view meshName,
    precice::string_view dataName,
    const int    *vertices,
    const double *gradientValues)
{
  fake_read_write_buffer.clear();
  for (int i = 0; i < size * this->getDimensions() * this->getDimensions(); i++) {
    fake_read_write_buffer.push_back(gradientValues[i]);
  }
}

void Participant:: setMeshAccessRegion
(
  precice::string_view meshName,
  const double* boundingBox ) const
{
    assert(meshName == fake_mesh_name);

    for(std::size_t i = 0; i < fake_bounding_box.size(); i++){
        assert(boundingBox[i] == fake_bounding_box[i]);
    }
}

void Participant:: getMeshVerticesAndIDs
(
  precice::string_view meshName,
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