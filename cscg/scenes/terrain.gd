extends MeshInstance3D

@onready var collision_shape = $StaticBody3D/CollisionShape3D
@export var chunk_size = 1.0
@export var height_ratio = 1.0
@export var collision_shape_size_ratio = 0.05

var shape = HeightMapShape3D.new()
var img = Image.new()

func _ready():
	collision_shape.shape = shape
	mesh.size = Vector2(chunk_size, chunk_size)
	update_terrain(height_ratio, collision_shape_size_ratio)
	#collision_shape.shape = mesh.create_trimesh_shape()


func update_terrain(collider_height_ratio, collider_shape_size_ratio):
	material_override.set("shader_param/height_ratio", collider_height_ratio)
	img.load("res://resources/height_map_600912875.png")
	img.convert(Image.FORMAT_RF)
	img.resize(img.get_width() * collider_shape_size_ratio, img.get_height() * collider_shape_size_ratio)
	var data = img.get_data().to_float32_array()
	for i in range(0, data.size()):
		data[i] *= collider_height_ratio
	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	shape.map_data = data
	var scale_ratio = chunk_size / float(img.get_width())
	collision_shape.scale = Vector3(scale_ratio, 1, scale_ratio)
	
	
