extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $SpringArm3D

@export var jump_height: float = 5.0
@export var cam_sens: float = 0.01

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_cam_rot: float = 0.15
var min_cam_rot: float = -0.75

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
	
	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * cam_sens
		if (spring_arm.rotation.x > min_cam_rot) and (spring_arm.rotation.x < max_cam_rot):
			spring_arm.rotation.x -= event.relative.y * cam_sens
