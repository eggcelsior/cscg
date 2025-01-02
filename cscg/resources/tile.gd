extends Node3D
class_name Tile

var center_position: Vector3 #should take from the center of the tile, not one of the vertices
var vertices: Array[Vector3]
var neighboring_tiles: Array[Tile]
var flattened: bool = false
var flat_neighbors: Array[Tile]
