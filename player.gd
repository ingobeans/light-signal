extends CharacterBody3D

@export_range(1, 35, 1) var speed: float = 10 
@export_range(10, 400, 1) var acceleration: float = 100 

@export var MAX_STEP_UP = 1

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var vertical := Vector3(0, 1, 0)
var horizontal := Vector3(1, 0, 1)

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 
var look_dir: Vector2 
var wish_dir: Vector3

var walk_vel: Vector3 
var grav_vel: Vector3 
var jump_vel: Vector3 

@onready var ladder_climb_pos = self.get_node("../LadderClimbPos")
@onready var ladder_climb_end_pos = self.get_node("../LadderEndPos")

var climbing = false
var lerping_towards_ladder = false
var lerping_towards_ladder_end = false
var climb_amt = 0

var has_key = true

@onready var camera: Camera3D = $Camera3D

func start_climb():
	climbing = true
	lerping_towards_ladder = true

func _ready() -> void:
	capture_mouse()

func lerp_towards(spot: Node3D, delta: float)->bool:
	global_position = global_position.move_toward(spot.global_position, 0.25 * delta)
	global_position = global_position.lerp(spot.global_position, 3 * delta)
	var delta_pos = global_position - spot.global_position
	
	camera.global_rotation = camera.global_rotation.move_toward(spot.global_rotation, 0.25 * delta)
	camera.global_rotation = camera.global_rotation.lerp(spot.global_rotation, 3 * delta)
	var delta_angle = camera.global_rotation - spot.global_rotation
	
	if delta_pos.length() <= 0.01 and delta_angle.length() < 0.01:
		global_position = spot.global_position
		camera.global_rotation = spot.global_rotation
		return true
	return false
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("release"):
		release_mouse()
	
	if lerping_towards_ladder:
		if lerp_towards(ladder_climb_pos,delta):
			lerping_towards_ladder = false
	elif lerping_towards_ladder_end:
		if lerp_towards(ladder_climb_end_pos,delta/2.0):
			lerping_towards_ladder_end = false
			climbing = false
	elif climbing:
		var axis = Input.get_axis("walk backwards","walk forwards")
		if global_position.y <= ladder_climb_pos.global_position.y:
			axis = max(axis,0)
		climb_amt += delta * axis
		position.y += axis * delta * speed / 4.0 * max(2*sin(2*PI / 1 * climb_amt)+1.0,0)
		if global_position.y >= 30.5:
			lerping_towards_ladder_end = true
		

func _unhandled_input(event: InputEvent) -> void:
	if climbing:
		return
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	elif event is InputEventMouseButton:
		capture_mouse()

func _physics_process(delta: float) -> void:
	if climbing:
		return
	if Input.is_action_just_pressed("jump"): jumping = true
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	if jump_vel.length() <= 0.0:
		stair_step_up()
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("walk left", "walk right", "walk forwards", "walk backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	wish_dir = walk_dir
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else Vector3(0, grav_vel.y - gravity * delta, 0)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

# from: https://github.com/kelpysama/Godot-Stair-Step-Demo/blob/main/Scripts/player_character.gd
func stair_step_up():
	if wish_dir == Vector3.ZERO:
		return

	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform
	var distance = wish_dir * 0.1
	body_test_params.from = self.global_transform		
	body_test_params.motion = distance
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return
	
	var remainder = body_test_result.get_remainder()
	test_transform = test_transform.translated(body_test_result.get_travel())	
	
	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())										
	
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()
		
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical
	
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())
	
	var surface_normal = body_test_result.get_collision_normal()
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > floor_max_angle):
		return

	var global_pos = global_position

	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos
