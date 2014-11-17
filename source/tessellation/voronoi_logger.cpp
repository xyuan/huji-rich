#include <fstream>
#include "voronoi_logger.hpp"
#include "../misc/simple_io.hpp"
#include "VoronoiMesh.hpp"

using namespace voronoi_loggers;

VoronoiLogger::VoronoiLogger(void) {}

void VoronoiLogger::output(VoronoiMesh const& /*v*/) {}

void VoronoiLogger::output(Tessellation const& /*v*/) {}

VoronoiLogger::~VoronoiLogger(void) {}

BinLogger::BinLogger(string const& file_name):
file_name_(file_name) {}

void BinLogger::output(Tessellation const& v)
{
	ofstream file_handle(file_name_.c_str(),ios::binary);

	binary_write_single_int((int)v.GetTotalSidesNumber(),file_handle);

	for(int i=0;i<(int)v.GetTotalSidesNumber();++i)
	{
		Edge edge=v.GetEdge(i);
		binary_write_single_double(edge.vertices.first.x,file_handle);
		binary_write_single_double(edge.vertices.second.x,file_handle);
	}

	for(int i=0;i<(int)v.GetTotalSidesNumber();++i)
	{
		Edge edge=v.GetEdge(i);
		binary_write_single_double(edge.vertices.first.y,file_handle);
		binary_write_single_double(edge.vertices.second.y,file_handle);
	}

	for(int i=0;i<(int)v.GetTotalSidesNumber();++i)
	{
		Edge edge=v.GetEdge(i);
		binary_write_single_int(edge.neighbors.first,file_handle);
		binary_write_single_int(edge.neighbors.second,file_handle);
	}

	binary_write_single_int(v.GetPointNo(),file_handle);

	for(int i=0;i<(int)v.GetPointNo();++i)
	{
		binary_write_single_double(v.GetMeshPoint(i).x,file_handle);
		binary_write_single_double(v.GetMeshPoint(i).y,file_handle);
	}

	for(int i=0;i<(int)v.GetPointNo();++i)
	{
		const vector<int> indices = v.GetCellEdges(i);
		binary_write_single_int((int)indices.size(),file_handle);
		for(int j=0;j<(int)indices.size();++j)
		  binary_write_single_int(indices[(size_t)j],file_handle);
	}
	file_handle.close();
}

void BinLogger::output(VoronoiMesh const& v)
{
	ofstream file_handle(file_name_.c_str(),ios::binary);

	binary_write_single_int((int)v.GetTotalSidesNumber(),file_handle);

	for(int i=0;i<(int)v.GetTotalSidesNumber();++i)
	{
		Edge edge=v.GetEdge(i);
		binary_write_single_double(edge.vertices.first.x,file_handle);
		binary_write_single_double(edge.vertices.second.x,file_handle);
	}

	for(int i=0;i<(int)v.GetTotalSidesNumber();++i)
	{
		Edge edge=v.GetEdge(i);
		binary_write_single_double(edge.vertices.first.y,file_handle);
		binary_write_single_double(edge.vertices.second.y,file_handle);
	}

	for(int i=0;i<(int)v.GetTotalSidesNumber();++i)
	{
		Edge edge=v.GetEdge(i);
		binary_write_single_int(edge.neighbors.first,file_handle);
		binary_write_single_int(edge.neighbors.second,file_handle);
	}

	binary_write_single_int(v.GetPointNo(),file_handle);

	for(int i=0;i<(int)v.GetPointNo();++i)
	{
		binary_write_single_double(v.GetMeshPoint(i).x,file_handle);
		binary_write_single_double(v.GetMeshPoint(i).y,file_handle);
	}

	for(int i=0;i<(int)v.GetPointNo();++i)
	{
		const vector<int> indices = v.GetCellEdges(i);
		binary_write_single_int((int)indices.size(),file_handle);
		for(int j=0;j<(int)indices.size();++j)
		  binary_write_single_int(indices[(size_t)j],file_handle);
	}
	file_handle.close();
}

vector<Vector2D> BinLogger::read(string location)
{
	fstream myFile (location.c_str(),ios::in | ios::binary);
	if(!myFile.good())
		throw UniversalError("Error opening voronoi logger file!!");
	int N;
	myFile.read((char*)&N,sizeof (int));
	double temp;
	for(int i=0;i<N*4;++i)
		myFile.read((char*)&temp,sizeof(double));
	myFile.read((char*)&N,sizeof (int));
	vector<Vector2D> res((size_t)N);
	for(size_t i=0;i<(size_t)N;++i)
	{
		myFile.read((char*)&res[i].x,sizeof(double));
		myFile.read((char*)&res[i].y,sizeof(double));
	}
	return res;
}
