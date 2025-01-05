extends CharacterBody3D
class_name Player

var speed
var jump_velocity: float = 4.5

@export var sensitivity = 0.004

var gravity: float = 9.8
var bob_frequency: float = 2.0
var bob_amplitude: float = 0.08
var t_bob = 0.0 #Time in bob

@onready var ray: RayCast3D = $head/Camera3D/RayCast3D
@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/Camera3D
@onready var line_renderer: Node3D = $"../LineRenderer"

var current_tile: Tile #The tile you're lookin at

#region Player Stats
var walk_speed: float = 3.5
var sprint_speed: float = 5.0
var attack_damage: float = 1.0
var defense: float = 1.0
var gather_speed: float = 1.0
var mine_speed: float = 1.0
var mining_chance: float = 0.1
var gathering_chance: float = 0.1
var hunting_chance: float = 0.1

var hunger: float = 100.0
var health: float = 100.0
@export var player_range: float = 32
#endregion

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if !is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed
	
	find_closest_tile()
	
	if Input.is_action_just_pressed("left_click"):
		ray.target_position = Vector3(0, 0, -150)
		ray.force_raycast_update()
		
		if ray.is_colliding():
			var collider = ray.get_collider()
			var point = ray.get_collision_point()
			if collider.get_parent() is GenTest:
				current_tile = collider.get_parent().find_closest_tile(point)
				#if (current_tile.center_position).distance_squared_to(global_position - collider.global_position) > collider.get_parent().tile_size * player_range:
				if global_position.distance_squared_to(point) > player_range:
					return
				collider.get_parent().deform_tile(point, 0)
				#line_renderer.clear_meshes()
				#line_renderer.render_line(current_tile.vertices_position[0], current_tile.vertices_position[1])
				#line_renderer.render_line(current_tile.vertices_position[0], current_tile.vertices_position[2])
				#line_renderer.render_line(current_tile.vertices_position[2], current_tile.vertices_position[3])
				#line_renderer.render_line(current_tile.vertices_position[3], current_tile.vertices_position[1])
				
	if Input.is_action_just_pressed("right_click"):
		ray.target_position = Vector3(0, 0, -150)
		ray.force_raycast_update()
		
		if ray.is_colliding():
			var collider = ray.get_collider()
			var point = ray.get_collision_point()
			if collider.get_parent() is GenTest:
				current_tile = collider.get_parent().find_closest_tile(point)
				#if (current_tile.center_position).distance_squared_to(global_position - collider.global_position) > collider.get_parent().tile_size * player_range:
				if global_position.distance_squared_to(point) > player_range:
					return
				collider.get_parent().deform_tile(point, 1)
				#line_renderer.clear_meshes()
				#line_renderer.render_line(current_tile.vertices_position[0], current_tile.vertices_position[1])
				#line_renderer.render_line(current_tile.vertices_position[0], current_tile.vertices_position[2])
				#line_renderer.render_line(current_tile.vertices_position[2], current_tile.vertices_position[3])
				#line_renderer.render_line(current_tile.vertices_position[3], current_tile.vertices_position[1])

	if Input.is_action_just_pressed("middle_click"):
		ray.target_position = Vector3(0, 0, -150)
		ray.force_raycast_update()
		
		if ray.is_colliding():
			var collider = ray.get_collider()
			var point = ray.get_collision_point()
			if collider.get_parent() is GenTest:
				current_tile = collider.get_parent().find_closest_tile(point)
				#if (current_tile.center_position).distance_squared_to(global_position - collider.global_position) > collider.get_parent().tile_size * player_range:
				if global_position.distance_squared_to(point) > player_range:
					return
				collider.get_parent().deform_tile(point, 3)
				#line_renderer.clear_meshes()
				#line_renderer.render_line(current_tile.vertices_position[0], current_tile.vertices_position[1])
				#line_renderer.render_line(current_tile.vertices_position[0], current_tile.vertices_position[2])
				#line_renderer.render_line(current_tile.vertices_position[2], current_tile.vertices_position[3])
				#line_renderer.render_line(current_tile.vertices_position[3], current_tile.vertices_position[1])
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var dir = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if dir:
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
		else:
			velocity.x = lerp(velocity.x, dir.x * speed, delta * 7)
			velocity.z = lerp(velocity.z, dir.z * speed, delta * 7)
	else:
		velocity.x = lerp(velocity.x, dir.x * speed, delta * 3)
		velocity.z = lerp(velocity.z, dir.z * speed, delta * 3)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(t_bob)
		
	move_and_slide()

func headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_frequency) * bob_amplitude
	pos.x = cos(time * bob_frequency / 2) * bob_amplitude
	return pos

func find_closest_tile():
	ray.target_position = Vector3(0, 0, -150)
	ray.force_raycast_update()
		
	if ray.is_colliding():
		var collider = ray.get_collider()
		var point = ray.get_collision_point()
		if collider.get_parent() is GenTest:
			current_tile = collider.get_parent().find_closest_tile(point)
			
			if global_position.distance_squared_to(point) > player_range:
				line_renderer.clear_meshes()
				return
			#if (current_tile.center_position).distance_squared_to(global_position - collider.global_position) > collider.get_parent().tile_size * player_range:
				#line_renderer.clear_meshes()
				#return
			line_renderer.clear_meshes()
			line_renderer.render_line(current_tile.vertices_position[0] + collider.global_position, current_tile.vertices_position[1] + collider.global_position)
			line_renderer.render_line(current_tile.vertices_position[0] + collider.global_position, current_tile.vertices_position[2] + collider.global_position)
			line_renderer.render_line(current_tile.vertices_position[2] + collider.global_position, current_tile.vertices_position[3] + collider.global_position)
			line_renderer.render_line(current_tile.vertices_position[3] + collider.global_position, current_tile.vertices_position[1] + collider.global_position)
