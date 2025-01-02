extends Node2D
class_name HeightmapGenerator

var height_noise: FastNoiseLite
var height_map: PackedFloat64Array
@export var resolution: int = 1024

func _ready():
	init_noise()
	generate_heightmap()
	save()
	
func init_noise():
	height_noise = FastNoiseLite.new()
	height_noise.seed = randi()
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN #Perlin is default but in case you want to change it change it here
	height_noise.frequency = 0.001
	
func generate_heightmap():
	for y in resolution:
		for x in resolution:
			var value = height_noise.get_noise_2d(x, y)
			height_map.append(value)
			
func save():
	var image: Image = Image.new()
	image.create(resolution, resolution, false, Image.FORMAT_RGB8)
	
	var buffer = PackedByteArray()
	buffer.resize(resolution * resolution * 3)
	buffer = image.get_data()
	
	for y in resolution:
		for x in resolution:
			var greyscale_val = int((height_map[y * resolution + x] + 1) * 127.5)
			#R G B
			buffer.append(greyscale_val)
			buffer.append(greyscale_val)
			buffer.append(greyscale_val)
			
	image.set_data(resolution, resolution, false, Image.FORMAT_RGB8, buffer)
	image.save_png("res://resources/height_map" + "_" + str(height_noise.seed) + ".png")
