extends CharacterBody3D

var speed
var walk_speed: float = 5.0
var sprint_speed: float = 8.0
var jump_velocity: float = 4.5

@export var sensitivity = 0.004

var gravity: float = 9.8
var bob_frequency: float = 2.0
var bob_amplitude: float = 0.08
var t_bob = 0.0 #Time in bob

@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/Camera3D



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if !is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed
	
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
