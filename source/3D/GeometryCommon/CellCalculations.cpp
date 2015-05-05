//\file CellCalculations.cpp
//\brief Performs various calculations on cells

#include "CellCalculations.hpp"
#include <vector>
#include <boost/unordered_set.hpp>
#include "VectorRepository.hpp"

using namespace std;

//\brief Splits a cell into tetrahedra, all touching the center of the cell
void SplitCell(const std::vector<const Face *> &cell, std::vector<Tetrahedron> &tetrahedra)
{
	Vector3D center;
	boost::unordered::unordered_set<VectorRef, VectorRefHasher> considered;
	size_t expectedNumTetrahedra = 0;  // Total number of expected tetrahedra, to save on reallocations

	// Find the center of the cell (an average of all the vertices)
	for (std::vector<const Face *>::const_iterator itFace = cell.begin(); itFace != cell.end(); itFace++)
	{
		const Face *face = *itFace;
		expectedNumTetrahedra += face->vertices.size() - 1;

		for (std::vector<VectorRef>::const_iterator itVertex = face->vertices.begin(); itVertex != face->vertices.end(); itVertex++)
		{
			if (considered.find(*itVertex) != considered.end())  // See if we've used this vertex before
				continue;
			considered.insert(*itVertex);
			center += **itVertex;
		}
	}
	center = center / (double)considered.size();   // Average
	VectorRef centerRef(center);

	tetrahedra.clear();
	tetrahedra.reserve(expectedNumTetrahedra);

	// Now create the tetrahedra, from the center to each of the faces
	for (std::vector<const Face *>::const_iterator itFace = cell.begin(); itFace != cell.end(); itFace++)
	{
		const Face *face = *itFace;
		// Split the face into trianges (face[0], face[1], face[2]), (face[0], face[2], face[3]) and so on until (face[0], face[n-2], face[n-1])
		// add center to each triangle, providing the tetrahedron
		for (size_t i = 1; i < face->vertices.size() - 1; i++)
		{
			Tetrahedron t(centerRef, face->vertices[0], face->vertices[i], face->vertices[i + 1]);
			tetrahedra.push_back(t);
		}
	}
}

//\brief Calculates the volume and center-of-mass of a cell
void CalculateCellDimensions(const std::vector<const Face *> &cell, double &volume, Vector3D &centerOfMass)
{
	std::vector<Tetrahedron> tetrahedra;
	SplitCell(cell, tetrahedra);

	volume = 0;
	centerOfMass = Vector3D();

	for (size_t j = 0; j < tetrahedra.size(); j++)
		volume += tetrahedra[j].volume();

	for (size_t j = 0; j < tetrahedra.size(); j++)
	{
		// This function is sometimes called with degenerate faces (before faces are optimized). This
		// results in degenerate tetrahedra. We just ignore them here.
		double tetrahedronVolume = tetrahedra[j].volume();
		if (tetrahedronVolume < 1e-30)
			continue;
		Vector3D weightedCenter = tetrahedra[j].center() * tetrahedronVolume;
		centerOfMass += weightedCenter;
	}

	centerOfMass = centerOfMass / volume;
}
