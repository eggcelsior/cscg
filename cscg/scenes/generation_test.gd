extends MeshInstance3D
class_name GenTest

var tiles = []
@export var resolution: int = 16
@export var heightmap: FastNoiseLite

func _ready():
	tiles.resize(resolution)
	for i in tiles.size():
		tiles[i] = []
		tiles[i].resize(resolution)
		for j in tiles[i].size():
			tiles[i][j] = Tile.new()
			var new_tile: Tile = tiles[i][j]
			new_tile.center_position = Vector3(j, 0, i)
			new_tile.vertices.resize(4)
			new_tile.neighboring_tiles.resize(4)
			new_tile.vertices_position.resize(4)
			for k in 4:
				match k:
					0:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x - 0.5, 0, new_tile.center_position.z - 0.5)
					1:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x + 0.5, 0, new_tile.center_position.z - 0.5)
					2:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x - 0.5, 0, new_tile.center_position.z + 0.5)
					3:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x + 0.5, 0, new_tile.center_position.z + 0.5)
	generate()
func generate():
	var x_count = 0
	var y_count = 0
	var vertex_data: PackedFloat32Array = []
	for i in resolution * 2:
		for j in resolution * 2:
			vertex_data.append(heightmap.get_noise_2d(j, i))
	var previous_position = 0
	var sorted_vectors = []
	for y in resolution:
		for x in resolution:
			for i in 4:
				tiles[y][x].vertices[i] = vertex_data[previous_position]
				previous_position += 1
				tiles[y][x].vertices_position[i].y = tiles[y][x].vertices[i]
				sorted_vectors.append(tiles[y][x].vertices_position[i])
	
	print(tiles[0][0].vertices_position, "\n", tiles[0][1].vertices_position)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.set_smooth_group(-1)
	st.add_vertex(Vector3(0, 1, 0))
	st.add_vertex(Vector3(1, 0, 0))
	st.add_vertex(Vector3(1, 0, 1))
	#for v in vertex_data:
		#st.add_vertex(sorted_vectors[v])
	st.generate_normals()
	st.index()
	
	mesh = st.commit()
