#include "precice/Participant.hpp"
#include "precice/Tooling.hpp"
#include <iostream>
#include <numeric>
#include <cassert>
#include <vector>

std::string fake_version;
std::vector<double> fake_read_write_buffer;
int fake_mesh_dimensions;
int fake_scalar_data_dimensions;
int fake_vector_data_dimensions;
std::vector<int> fake_ids;
int n_fake_vertices;
std::string fake_mesh_name;
std::string fake_scalar_data_name;
std::string fake_vector_data_name;
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
  fake_scalar_data_dimensions = 1;
  fake_vector_data_dimensions = 3;
  fake_data_id = 15;
  fake_mesh_name = "FakeMesh";
  fake_scalar_data_name = "FakeScalarData";
  fake_vector_data_name = "FakeVectorData";
  n_fake_vertices = 3;
  fake_ids.resize(n_fake_vertices);
  std::iota(fake_ids.begin(), fake_ids.end(), 0);
  fake_bounding_box.resize(fake_mesh_dimensions*2);
  std::iota(fake_bounding_box.begin(), fake_bounding_box.end(), 0);
  fake_coordinates.resize(n_fake_vertices*fake_mesh_dimensions);
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
  fake_scalar_data_dimensions = 1;
  fake_vector_data_dimensions = 3;
  fake_data_id = 15;
  fake_mesh_name = "FakeMesh";
  fake_scalar_data_name = "FakeScalarData";
  fake_vector_data_name = "FakeVectorData";
  n_fake_vertices = 3;
  fake_ids.resize(n_fake_vertices);
  std::iota(fake_ids.begin(), fake_ids.end(), 0);
  fake_bounding_box.resize(fake_mesh_dimensions*2);
  std::iota(fake_bounding_box.begin(), fake_bounding_box.end(), 0);
}

Participant::~Participant() = default;

void Participant:: initialize()
{
}

void Participant:: advance
(
  double computedTimestepLength )
{
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
  if (dataName.data() == fake_scalar_data_name) {
    return fake_scalar_data_dimensions;
  } else if (dataName.data() == fake_vector_data_name) {
    return fake_vector_data_dimensions;
  } else {
    return -1;
  }
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
  return -1.0;
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
  precice::span<const double> position )
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
  precice::span<const double> positions,
  precice::span<precice::VertexID> ids )
{
  if(ids.size() > 0) {
    assert (ids.size() == fake_ids.size());
    std::copy(fake_ids.begin(), fake_ids.end(), ids.data());
  }
}

void Participant:: setMeshEdge
(
  precice::string_view meshName,
  int firstVertexID,
  int secondVertexID )
{}

void Participant::setMeshEdges(
    precice::string_view meshName,
    precice::span<const precice::VertexID> vertices)
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
  precice::span<const precice::VertexID> vertices )
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
  precice::span<const precice::VertexID> vertices)
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
    precice::span<const precice::VertexID> vertices)
{}

void Participant:: writeData
(
  precice::string_view meshName,
  precice::string_view dataName,
  precice::span<const precice::VertexID> vertices,
  precice::span<const double> values)
{
  fake_read_write_buffer.clear();

  for(const double value: values) {
    fake_read_write_buffer.push_back(value);
  }
}

void Participant:: readData
(
  precice::string_view meshName,
  precice::string_view dataName,
  precice::span<const precice::VertexID> vertices,
  double  relativeReadTime,
  precice::span<double> values) const
{
  if (dataName.data() == fake_scalar_data_name) {
    for(const int id: vertices) {
      values[id] = fake_read_write_buffer[id];
    }
  } else if (dataName.data() == fake_vector_data_name) {
    for(const int id: vertices) {
      for(int d = 0; d < fake_vector_data_dimensions; d++) {
        const int linearized_id = fake_vector_data_dimensions * id + d;
        values[linearized_id] = fake_read_write_buffer[linearized_id];
      }
    }
  }
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
    precice::span<const precice::VertexID> vertices,
    precice::span<const double> gradients)
{
  fake_read_write_buffer.clear();
  for (const double gradient: gradients) {
    fake_read_write_buffer.push_back(gradient);
  }
}

void Participant:: setMeshAccessRegion
(
  precice::string_view meshName,
  precice::span<const double> boundingBox ) const
{
    assert(meshName == fake_mesh_name);

    for(std::size_t i = 0; i < fake_bounding_box.size(); i++){
        assert(boundingBox[i] == fake_bounding_box[i]);
    }
}

void Participant:: getMeshVerticesAndIDs
(
  precice::string_view meshName,
  precice::span<int> valueIndices,
  precice::span<double> coordinates ) const
{
    assert(meshName == fake_mesh_name);
    assert(valueIndices.size() == fake_ids.size());
    assert(coordinates.size() == fake_coordinates.size());

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