extends MeshInstance3D
class_name GenTest

var tiles = []
@export var resolution: int = 16
@export var heightmap: FastNoiseLite
@export var terrain_height_multiplyer: float = 10.0
@export var tile_size: float = 1

func _ready():
	tiles.resize(resolution)
	for i in tiles.size():
		tiles[i] = []
		tiles[i].resize(resolution)
		for j in tiles[i].size():
			tiles[i][j] = Tile.new()
			var new_tile: Tile = tiles[i][j]
			new_tile.center_position = Vector3(j*tile_size, 0, i*tile_size)
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

func deform_tile(ray_pos: Vector3):
	var closest_tile: Tile = null
	var closest_distance: float = INF
	
	for y in resolution:
		for x in resolution:
			var distance: float = ray_pos.distance_squared_to(tiles[y][x].center_position)
			if distance < closest_distance:
				closest_tile = tiles[y][x]
				closest_distance = distance
	#SHOULD NOW HAVE CLOSEST TILE
	var smallest_vertex: float
	var smallest_value: float = INF
	for i in 4:
		if closest_tile.vertices[i] < smallest_value:
			smallest_vertex = closest_tile.vertices[i]
			smallest_value = closest_tile.vertices[i]
	#NOW HAS SMALLEST VERTEX VALUE
	##SMALLEST VERTEX VALUE CAN MAKE THE TILE GO UP OR DOWN DEPENDING ON ITS VALUE (DOESN'T HAVE TO BE SMALLEST RIGHT NOW, THAT'S JUST FOR FLATTENING LMAO)
	for i in 4:
		closest_tile.vertices[i] = smallest_vertex
	#if closest_tile.bottom_left != null:
		#closest_tile.bottom_left.vertices[3] = smallest_vertex
	if closest_tile.left != null:
		if closest_tile.left.bottom_middle != null:
			closest_tile.left.bottom_middle.vertices[3] = smallest_vertex
		
	if closest_tile.bottom_middle != null:
		closest_tile.bottom_middle.vertices[2] = smallest_vertex
		closest_tile.bottom_middle.vertices[3] = smallest_vertex
		
	#if closest_tile.bottom_right != null:
		#closest_tile.bottom_right.vertices[2] = smallest_vertex
	if closest_tile.right != null:
		if closest_tile.right.bottom_middle != null:
			closest_tile.right.bottom_middle.vertices[2] = smallest_vertex
		
	if closest_tile.left != null:
		closest_tile.left.vertices[1] = smallest_vertex
		closest_tile.left.vertices[3] = smallest_vertex
		
	if closest_tile.right != null:
		closest_tile.right.vertices[0] = smallest_vertex
		closest_tile.right.vertices[2] = smallest_vertex
		
	#if closest_tile.top_left != null:
		#closest_tile.top_left.vertices[1] = smallest_vertex
	if closest_tile.left != null:
		if closest_tile.left.top_middle != null:
			closest_tile.left.top_middle.vertices[1] = smallest_vertex
		
	if closest_tile.top_middle != null:
		closest_tile.top_middle.vertices[0] = smallest_vertex
		closest_tile.top_middle.vertices[1] = smallest_vertex
		
	#if closest_tile.top_right != null:
		#closest_tile.top_right.vertices[0] = smallest_vertex
	if closest_tile.right != null:
		if closest_tile.right.top_middle != null:
			closest_tile.right.top_middle.vertices[0] = smallest_vertex
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
	var start_noise_position = Vector2(1, 1)
	var multiplyer := terrain_height_multiplyer * tile_size
	for y in resolution:
		for x in resolution:
			tiles[y][x].vertices[0] = heightmap.get_noise_2d(start_noise_position.x, start_noise_position.y) * multiplyer
			tiles[y][x].vertices[1] = heightmap.get_noise_2d(start_noise_position.x+1, start_noise_position.y) * multiplyer
			tiles[y][x].vertices[2] = heightmap.get_noise_2d(start_noise_position.x, start_noise_position.y+1) * multiplyer
			tiles[y][x].vertices[3] = heightmap.get_noise_2d(start_noise_position.x+1, start_noise_position.y+1) * multiplyer
			start_noise_position.x += 1
		start_noise_position.x = 1
		start_noise_position.y += 1
	#var previous_position = 0
	#var sorted_vectors = []
	#for y in resolution:
		#for x in resolution:
			#for i in 4:
				#tiles[y][x].vertices[i] = vertex_data[previous_position]
				#previous_position += 1
				#tiles[y][x].vertices_position[i].y = tiles[y][x].vertices[i]
				#sorted_vectors.append(tiles[y][x].vertices_position[i])
	
	#print(tiles[0][0].vertices_position, "\n", tiles[0][1].vertices_position)
	locate_neighbors()
	for y in resolution:
		for x in resolution:
			for i in 4:
				tiles[y][x].vertices_position[i].y = tiles[y][x].vertices[i]
			#print(tiles[y][x].vertices)
			#if x % 2 != 0:
				#print("\n\n")
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
			#END CHECK CORNERS
			
			##CHECK VERTICES
			##CHECK BOTTOM LEFT
			#if left != null && left.vertices[1] < tiles[y][x].vertices[0]:
				#tiles[y][x].vertices[0] = left.vertices[1]
			#else:
				#if left != null:
					#left.vertices[1] = tiles[y][x].vertices[0]
			#if bottom_left != null && bottom_left.vertices[3] < tiles[y][x].vertices[0]:
				#tiles[y][x].vertices[0] = bottom_left.vertices[3]
			#else:
				#if bottom_left != null:
					#bottom_left.vertices[3] = tiles[y][x].vertices[0]
			#if bottom_middle != null && bottom_middle.vertices[2] < tiles[y][x].vertices[0]:
				#tiles[y][x].vertices[0] = bottom_middle.vertices[2]
			#else:
				#if bottom_middle != null:
					#bottom_middle.vertices[2] = tiles[y][x].vertices[0]
			##CHECK BOTTOM RIGHT
			#if bottom_middle != null && bottom_middle.vertices[3] < tiles[y][x].vertices[1]:
				#tiles[y][x].vertices[1] = bottom_middle.vertices[3]
			#else:
				#if bottom_middle != null:
					#bottom_middle.vertices[3] = tiles[y][x].vertices[1]
			#if bottom_right != null && bottom_right.vertices[2] < tiles[y][x].vertices[1]:
				#tiles[y][x].vertices[1] = bottom_right.vertices[2]
			#else:
				#if bottom_right != null:
					#bottom_right.vertices[2] = tiles[y][x].vertices[0]
			#if right != null && right.vertices[0] < tiles[y][x].vertices[1]:
				#tiles[y][x].vertices[1] = right.vertices[0]
			#else:
				#if right != null:
					#right.vertices[0] = tiles[y][x].vertices[1]
			##CHECK TOP RIGHT
			#if right != null && right.vertices[2] < tiles[y][x].vertices[3]:
				#tiles[y][x].vertices[3] = right.vertices[2]
			#else:
				#if right != null:
					#right.vertices[2] = tiles[y][x].vertices[3]
			#if top_right != null && top_right.vertices[0] < tiles[y][x].vertices[3]:
				#tiles[y][x].vertices[3] = top_right.vertices[0]
			#else:
				#if top_right != null:
					#top_right.vertices[0] = tiles[y][x].vertices[3]
			#if top_middle != null && top_middle.vertices[1] < tiles[y][x].vertices[3]:
				#tiles[y][x].vertices[3] = top_middle.vertices[1]
			#else:
				#if top_middle != null:
					#top_middle.vertices[1] = tiles[y][x].vertices[3]
			##CHECK TOP LEFT
			#if top_middle != null && top_middle.vertices[0] < tiles[y][x].vertices[2]:
				#tiles[y][x].vertices[2] = top_middle.vertices[0]
			#else:
				#if top_middle != null:
					#top_middle.vertices[0] = tiles[y][x].vertices[2]
			#if top_left != null && top_left.vertices[1] < tiles[y][x].vertices[2]:
				#tiles[y][x].vertices[2] = top_left.vertices[1]
			#else:
				#if top_left != null:
					#top_left.vertices[1] = tiles[y][x].vertices[2]
			#if left != null && left.vertices[3] < tiles[y][x].vertices[2]:
				#tiles[y][x].vertices[2] = left.vertices[3]
			#else:
				#if left != null:
					#left.vertices[3] = tiles[y][x].vertices[2]
			##END CHECK VERTICES
	#print(tiles[1][2].vertices[2], " ", tiles[1][2].vertices[3], "___", tiles[1][3].vertices[2], " ", tiles[1][3].vertices[3])
	#print(tiles[1][2].vertices[0], " ", tiles[1][2].vertices[1], "___", tiles[1][3].vertices[0], " ", tiles[1][3].vertices[1])
	#print(tiles[0][2].vertices[2], " ", tiles[0][2].vertices[3], "___", tiles[0][3].vertices[2], " ", tiles[0][3].vertices[3])
	#print(tiles[0][2].vertices[0], " ", tiles[0][2].vertices[1], "___", tiles[0][3].vertices[0], " ", tiles[0][3].vertices[1])
		#
