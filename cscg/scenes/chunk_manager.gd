extends Node3D
class_name ChunkManager

var chunks = []
@export var render_distance: int = 16
@export var resolution: int = 16
@export var heightmap: FastNoiseLite
@export var terrain_height_multiplyer: float = 10.0
@export var tile_size: float = 2

@onready var chunk_scene = preload("res://scenes/chunk.tscn")

func _ready():
	chunks.resize(16)
	var world_position = Vector3(0, 0, 0)
	for y in chunks.size():
		chunks[y] = []
		chunks[y].resize(16)
		for x in chunks.size():
			var instance = chunk_scene.instantiate()
			chunks[y][x] = instance
			add_child(chunks[y][x])
			chunks[y][x].set_data(resolution, heightmap, terrain_height_multiplyer, tile_size)
			chunks[y][x].global_position = world_position
			world_position.x += resolution #* tile_size
			chunks[y][x].init_chunk()
		world_position.z += resolution #* tile_size
		world_position.x = 0
