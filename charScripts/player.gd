extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var spring_arm_pos: Node3D = $SpringArm3D/Pos
@onready var doodle: Sprite3D = $doodle
@onready var camera: Camera3D = $Camera3D

@export var speed: float = 5.0
@export var jump_height: float = 5.0
@export var cam_sens: float = 0.004 

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_cam_rot: float = 0.15
var min_cam_rot: float = -0.75
var last_mouse_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	#if Input.is_action_pressed("ui_cancel"):
		#if not get_tree().paused:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#if Input.is_action_pressed("left_click"):
		#if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			#get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	var input = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	var movement_dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if movement_dir:
		var move_angle = lerp_angle(0.0, atan2(movement_dir.x, movement_dir.z), 0.6)
		doodle.rotation.y = lerp_angle(doodle.rotation.y, move_angle, 0.15)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	camera.global_position = lerp(camera.global_position, spring_arm_pos.global_position, 0.05)
	camera.rotation.x = lerp_angle(camera.rotation.x, spring_arm.rotation.x, 0.05)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_height
		else:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	
	move_and_slide()
	
func _unhandled_input(event):
	if Input.is_action_pressed("right_click"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			last_mouse_pos = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x * cam_sens
			spring_arm.rotation.x = clamp(spring_arm.rotation.x - (event.relative.y * cam_sens), min_cam_rot, max_cam_rot)
	elif Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.warp_mouse(last_mouse_pos)
		
		
