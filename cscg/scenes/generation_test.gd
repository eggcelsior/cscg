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
			new_tile.neighboring_tiles.resize(8)
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
	#var x_count = 0
	#var y_count = 0
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
	
	#print(tiles[0][0].vertices_position, "\n", tiles[0][1].vertices_position)
	locate_neighbors()
	print(tiles[1][0].vertices, "\n", tiles[1][1].vertices)
	return
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.set_smooth_group(-1)
	st.add_vertex(Vector3(0, 0, 0))
	st.add_vertex(Vector3(1, 0, 0))
	st.add_vertex(Vector3(1, 0, 1))
	#for v in vertex_data:
		#st.add_vertex(sorted_vectors[v])
	st.generate_normals()
	st.index()
	
	mesh = st.commit()

func locate_neighbors():
	for y in resolution:
		for x in resolution:
			#var current_tile: Tile = tiles[y][x]
			
			var bottom_left: Tile
			var bottom_middle: Tile
			var bottom_right: Tile
			var left: Tile
			var right: Tile
			var top_left: Tile
			var top_middle: Tile
			var top_right: Tile
			
			#CHECK CARDINAL
			if x == 0:
				left = null
				right = tiles[y][x+1]
			elif x == 15:
				left = tiles[y][x-1]
				right = null
			else:
				left = tiles[y][x-1]
				right = tiles[y][x+1]
			if y == 0:
				bottom_middle = null
				top_middle = tiles[y+1][x]
			elif y == 15:
				top_middle = null
				bottom_middle = tiles[y-1][x]
			else:
				bottom_middle = tiles[y-1][x]
				top_middle = tiles[y+1][x]
			#END CHECK CARDINAL
			
			#CHECK CORNERS
			if y == 0:
				if x == 0:
					top_left = null
					top_right = tiles[y+1][x+1]
				elif x == 15:
					top_left = tiles[y+1][x-1]
					top_right = null
				else:
					top_left = tiles[y+1][x-1]
					top_right = tiles[y+1][x+1]
				bottom_left = null
				bottom_right = null
			elif y == 15:
				if x == 0:
					bottom_left = null
					bottom_right = tiles[y-1][x+1]
				elif x == 15:
					bottom_left = tiles[y-1][x-1]
					bottom_right = null
				else:
					bottom_left = tiles[y-1][x-1]
					bottom_right = tiles[y-1][x+1]
				top_left = null
				top_right = null
			else:
				if x == 0:
					top_left = null
					bottom_left = null
					top_right = tiles[y+1][x+1]
					bottom_right = tiles[y-1][x-1]
				elif x == 15:
					top_left = tiles[y+1][x-1]
					bottom_left = tiles[y-1][x-1]
					top_right = null
					top_left = null
				else:
					top_right = tiles[y+1][x+1]
					bottom_right = tiles[y-1][x-1]
					top_left = tiles[y+1][x-1]
					bottom_left = tiles[y-1][x-1]
			#END CHECK CORNERS
			
			#CHECK VERTICES
			#CHECK BOTTOM LEFT
			if left != null && left.vertices[1] < tiles[y][x].vertices[0]:
				tiles[y][x].vertices[0] = left.vertices[1]
			if bottom_left != null && bottom_left.vertices[3] < tiles[y][x].vertices[0]:
				tiles[y][x].vertices[0] = bottom_left.vertices[3]
			if bottom_middle != null && bottom_middle.vertices[2] < tiles[y][x].vertices[0]:
				tiles[y][x].vertices[0] = bottom_middle.vertices[2]
			#CHECK BOTTOM RIGHT
			if bottom_middle != null && bottom_middle.vertices[3] < tiles[y][x].vertices[1]:
				tiles[y][x].vertices[1] = bottom_middle.vertices[3]
			if bottom_right != null && bottom_right.vertices[2] < tiles[y][x].vertices[1]:
				tiles[y][x].vertices[1] = bottom_right.vertices[2]
			if right != null && right.vertices[0] < tiles[y][x].vertices[1]:
				tiles[y][x].vertices[1] = right.vertices[0]
			#CHECK TOP RIGHT
			if right != null && right.vertices[2] < tiles[y][x].vertices[3]:
				tiles[y][x].vertices[3] = right.vertices[2]
			if top_right != null && top_right.vertices[0] < tiles[y][x].vertices[3]:
				tiles[y][x].vertices[3] = top_right.vertices[0]
			if top_middle != null && top_middle.vertices[1] < tiles[y][x].vertices[3]:
				tiles[y][x].vertices[3] = top_middle.vertices[1]
			#CHECK TOP LEFT
			if top_middle != null && top_middle.vertices[0] < tiles[y][x].vertices[2]:
				tiles[y][x].vertices[2] = top_middle.vertices[0]
			if top_left != null && top_left.vertices[1] < tiles[y][x].vertices[2]:
				tiles[y][x].vertices[2] = top_left.vertices[1]
			if left != null && left.vertices[3] < tiles[y][x].vertices[2]:
				tiles[y][x].vertices[2] = left.vertices[3]
			#END CHECK VERTICES
