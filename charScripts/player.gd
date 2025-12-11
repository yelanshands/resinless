extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var doodle: Sprite3D = $doodle

@export var speed: float = 5.0
@export var jump_height: float = 5.0
@export var cam_sens: float = 0.004 

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_cam_rot: float = 0.15
var min_cam_rot: float = -0.75

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if not get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("left_click"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_viewport().set_input_as_handled()
			
func _physics_process(delta: float) -> void:
	var input = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	var movement_dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if movement_dir:
		doodle.rotation.y = lerp(doodle.rotation.y, atan2(movement_dir.x, movement_dir.z), 0.2)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_height
		else:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	
	move_and_slide()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * cam_sens
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - (event.relative.y * cam_sens), min_cam_rot, max_cam_rot)
		
