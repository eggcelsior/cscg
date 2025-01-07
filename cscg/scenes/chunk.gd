extends MeshInstance3D
class_name Chunk

var tiles = []
@export var resolution: int = 16
@export var heightmap: FastNoiseLite
@export var terrain_height_multiplyer: float = 10.0
@export var tile_size: float = 2

func init_chunk():
	tiles.resize(resolution)
	for i in tiles.size():
		tiles[i] = []
		tiles[i].resize(resolution)
		for j in tiles[i].size():
			tiles[i][j] = Tile.new()
			var new_tile: Tile = tiles[i][j]
			new_tile.center_position = Vector3((j + global_position.x / tile_size), 0, (i + global_position.z / tile_size))
			new_tile.center_position *= tile_size
			new_tile.vertices.resize(4)
			new_tile.vertices_position.resize(4)
			for k in 4:
				match k:
					0:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x - (tile_size / 2), 0, new_tile.center_position.z - (tile_size / 2))
					1:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x + (tile_size / 2), 0, new_tile.center_position.z - (tile_size / 2))
					2:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x - (tile_size / 2), 0, new_tile.center_position.z + (tile_size / 2))
					3:
						new_tile.vertices_position[k] = Vector3(new_tile.center_position.x + (tile_size / 2), 0, new_tile.center_position.z + (tile_size / 2))
	generate()

func set_data(resolution: int, heightmap: FastNoiseLite, terrain_height_multiplyer: float, tile_size: int):
	self.resolution = resolution
	self.heightmap = heightmap
	self.terrain_height_multiplyer = terrain_height_multiplyer
	self.tile_size = tile_size

func find_closest_tile(ray_pos: Vector3):
	var closest_tile: Tile = null
	var closest_distance: float = INF
	
	for y in resolution:
		for x in resolution:
			var distance: float = ray_pos.distance_squared_to(tiles[y][x].center_position + global_position) 
			if distance < closest_distance:
				closest_tile = tiles[y][x]
				closest_distance = distance
	return closest_tile

func deform_tile(ray_pos: Vector3, mouse_button: int):
	var closest_tile: Tile = find_closest_tile(ray_pos)
	#SHOULD NOW HAVE CLOSEST TILE
	var smallest_vertex: float
	var value: float = INF
	for i in 4:
		if closest_tile.vertices[i] < value:
			smallest_vertex = closest_tile.vertices[i]
			value = closest_tile.vertices[i]
	#NOW HAS SMALLEST VERTEX VALUE
	##SMALLEST VERTEX VALUE CAN MAKE THE TILE GO UP OR DOWN DEPENDING ON ITS VALUE (DOESN'T HAVE TO BE SMALLEST RIGHT NOW, THAT'S JUST FOR FLATTENING LMAO)
	if mouse_button == 3:
		for i in 4:
			closest_tile.vertices[i] = value

		if closest_tile.left != null:
			if closest_tile.left.bottom_middle != null:
				closest_tile.left.bottom_middle.vertices[3] = value
			
		if closest_tile.bottom_middle != null:
			closest_tile.bottom_middle.vertices[2] = value
			closest_tile.bottom_middle.vertices[3] = value
			
		if closest_tile.right != null:
			if closest_tile.right.bottom_middle != null:
				closest_tile.right.bottom_middle.vertices[2] = value
			
		if closest_tile.left != null:
			closest_tile.left.vertices[1] = value
			closest_tile.left.vertices[3] = value
			
		if closest_tile.right != null:
			closest_tile.right.vertices[0] = value
			closest_tile.right.vertices[2] = value
			
		if closest_tile.left != null:
			if closest_tile.left.top_middle != null:
				closest_tile.left.top_middle.vertices[1] = value
			
		if closest_tile.top_middle != null:
			closest_tile.top_middle.vertices[0] = value
			closest_tile.top_middle.vertices[1] = value
			
		if closest_tile.right != null:
			if closest_tile.right.top_middle != null:
				closest_tile.right.top_middle.vertices[0] = value
	else:
		if mouse_button == 0:
			value = -0.5 #MAYBE CHANGE
		if mouse_button == 1:
			value = 0.5 #MAYBE CHANGE
		for i in 4:
			closest_tile.vertices[i] += value

		if closest_tile.left != null:
			if closest_tile.left.bottom_middle != null:
				closest_tile.left.bottom_middle.vertices[3] += value
			
		if closest_tile.bottom_middle != null:
			closest_tile.bottom_middle.vertices[2] += value
			closest_tile.bottom_middle.vertices[3] += value
			
		if closest_tile.right != null:
			if closest_tile.right.bottom_middle != null:
				closest_tile.right.bottom_middle.vertices[2] += value
			
		if closest_tile.left != null:
			closest_tile.left.vertices[1] += value
			closest_tile.left.vertices[3] += value
			
		if closest_tile.right != null:
			closest_tile.right.vertices[0] += value
			closest_tile.right.vertices[2] += value
			
		if closest_tile.left != null:
			if closest_tile.left.top_middle != null:
				closest_tile.left.top_middle.vertices[1] += value
			
		if closest_tile.top_middle != null:
			closest_tile.top_middle.vertices[0] += value
			closest_tile.top_middle.vertices[1] += value
			
		if closest_tile.right != null:
			if closest_tile.right.top_middle != null:
				closest_tile.right.top_middle.vertices[0] += value
	rebuild_mesh()

func rebuild_mesh():
	for y in resolution:
		for x in resolution:
			for i in 4:
				tiles[y][x].vertices_position[i].y = tiles[y][x].vertices[i]
	
	mesh = null
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	
	for y in resolution:
		for x in resolution:
				st.add_vertex(tiles[y][x].vertices_position[0])
				st.add_vertex(tiles[y][x].vertices_position[1])
				st.add_vertex(tiles[y][x].vertices_position[2])
				st.add_vertex(tiles[y][x].vertices_position[3])
				st.add_vertex(tiles[y][x].vertices_position[2])
				st.add_vertex(tiles[y][x].vertices_position[1])
	st.generate_normals()
	st.index()
	
	mesh = st.commit()
	$StaticBody3D/CollisionShape3D.shape = mesh.create_trimesh_shape()
	
func generate():
	#var x_count = 0
	#var y_count = 0
	var vertex_data: PackedFloat32Array = []
	var start_noise_position = Vector2(1+global_position.x, 1+global_position.z)
	var multiplyer := terrain_height_multiplyer * tile_size
	for y in resolution:
		for x in resolution:
			tiles[y][x].vertices[0] = heightmap.get_noise_2d(start_noise_position.x, start_noise_position.y) * multiplyer
			tiles[y][x].vertices[1] = heightmap.get_noise_2d(start_noise_position.x+1, start_noise_position.y) * multiplyer
			tiles[y][x].vertices[2] = heightmap.get_noise_2d(start_noise_position.x, start_noise_position.y+1) * multiplyer
			tiles[y][x].vertices[3] = heightmap.get_noise_2d(start_noise_position.x+1, start_noise_position.y+1) * multiplyer
			start_noise_position.x += 1
		start_noise_position.x = 1+global_position.x
		start_noise_position.y += 1
	locate_neighbors()
	for y in resolution:
		for x in resolution:
			for i in 4:
				tiles[y][x].vertices_position[i].y = tiles[y][x].vertices[i]
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	
	for y in resolution:
		for x in resolution:
				st.add_vertex(tiles[y][x].vertices_position[0])
				st.add_vertex(tiles[y][x].vertices_position[1])
				st.add_vertex(tiles[y][x].vertices_position[2])
				st.add_vertex(tiles[y][x].vertices_position[3])
				st.add_vertex(tiles[y][x].vertices_position[2])
				st.add_vertex(tiles[y][x].vertices_position[1])
	st.generate_normals()
	st.index()
	
	mesh = st.commit()
	$StaticBody3D/CollisionShape3D.shape = mesh.create_trimesh_shape()

func locate_neighbors():
	for y in resolution:
		for x in resolution:
			#CHECK CARDINAL
			if x == 0:
				tiles[y][x].left = null
				tiles[y][x].right = tiles[y][x+1]
			elif x == resolution - 1:
				tiles[y][x].left = tiles[y][x-1]
				tiles[y][x].right = null
			else:
				tiles[y][x].left = tiles[y][x-1]
				tiles[y][x].right = tiles[y][x+1]
			if y == 0:
				tiles[y][x].bottom_middle = null
				tiles[y][x].top_middle = tiles[y+1][x]
			elif y == resolution - 1:
				tiles[y][x].top_middle = null
				tiles[y][x].bottom_middle = tiles[y-1][x]
			else:
				tiles[y][x].bottom_middle = tiles[y-1][x]
				tiles[y][x].top_middle = tiles[y+1][x]
			#END CHECK CARDINAL
			
			#CHECK CORNERS
			if y == 0:
				if x == 0:
					tiles[y][x].top_left = null
					tiles[y][x].top_right = tiles[y+1][x+1]
				elif x == resolution - 1:
					tiles[y][x].top_left = tiles[y+1][x-1]
					tiles[y][x].top_right = null
				else:
					tiles[y][x].top_left = tiles[y+1][x-1]
					tiles[y][x].top_right = tiles[y+1][x+1]
				tiles[y][x].bottom_left = null
				tiles[y][x].bottom_right = null
			elif y == resolution - 1:
				if x == 0:
					tiles[y][x].bottom_left = null
					tiles[y][x].bottom_right = tiles[y-1][x+1]
				elif x == resolution - 1:
					tiles[y][x].bottom_left = tiles[y-1][x-1]
					tiles[y][x].bottom_right = null
				else:
					tiles[y][x].bottom_left = tiles[y-1][x-1]
					tiles[y][x].bottom_right = tiles[y-1][x+1]
				tiles[y][x].top_left = null
				tiles[y][x].top_right = null
			else:
				if x == 0:
					tiles[y][x].top_left = null
					tiles[y][x].bottom_left = null
					tiles[y][x].top_right = tiles[y+1][x+1]
					tiles[y][x].bottom_right = tiles[y-1][x-1]
				elif x == resolution - 1:
					tiles[y][x].top_left = tiles[y+1][x-1]
					tiles[y][x].bottom_left = tiles[y-1][x-1]
					tiles[y][x].top_right = null
					tiles[y][x].top_left = null
				else:
					tiles[y][x].top_right = tiles[y+1][x+1]
					tiles[y][x].bottom_right = tiles[y-1][x-1]
					tiles[y][x].top_left = tiles[y+1][x-1]
					tiles[y][x].bottom_left = tiles[y-1][x-1]
