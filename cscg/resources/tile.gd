extends Node3D
class_name Tile

var center_position: Vector3 #should take from the center of the tile, not one of the vertices
var vertices: Array[float]
var vertices_position: Array[Vector3]
#var flattened: bool = false
#var flat_neighbors: Array[Tile]
#region NEIGHBORS
var bottom_left: Tile
var bottom_middle: Tile
var bottom_right: Tile
var left: Tile
var right: Tile
var top_left: Tile
var top_middle: Tile
var top_right: Tile
#endregion

func get_vertex_position_data():
	return vertices_position
