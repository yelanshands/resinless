extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var spring_arm_pos: Node3D = $SpringArm3D/Pos
@onready var doodle: Sprite3D = $doodle
@onready var camera: Camera3D = $Camera3D

@export var speed: float = 5.0
@export var jump_height: float = 5.0
@export var cam_sens: float = 0.004 
@export var drag_sens: float = 0.05
@export var reach: float = 15.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_cam_rot: float = 0.15
var min_cam_rot: float = -0.75
var last_mouse_pos: Vector2 = Vector2.ZERO
var mouse_pos: Vector2 = Vector2.ZERO
var object
var object_distance: float = 0.0
var dragging: bool = false
var rotating: bool = false

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
	
	if Input.is_action_pressed("left_click"):
		if not rotating:
			mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		if not dragging:
			var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * reach
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
			var result = space_state.intersect_ray(query)
			if result:
				object = result.collider
		if object:
			if object.has_method("on_clicked"):
				if not dragging:
					dragging = true
					object_distance = camera.global_position.distance_to(object.global_position)
				if not rotating:
					object.global_position = lerp(object.global_position, ray_origin + camera.project_ray_normal(mouse_pos) * object_distance, 0.2)
				else:
					object.global_position = ray_origin + camera.project_ray_normal(mouse_pos) * object_distance
	else:
		dragging = false
		object = null
	
	if Input.is_action_pressed("right_click"):
		if not rotating:
			rotating = true
			last_mouse_pos = get_viewport().get_mouse_position()
			print("1 ", get_viewport().get_mouse_position())
			if not mouse_pos:
				mouse_pos = last_mouse_pos
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif rotating:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.warp_mouse(last_mouse_pos)
		rotating = false
		print("2 ", get_viewport().get_mouse_position())
		# TS PMO IM GENUINELY REACHING SOLID STATE HELP ME 
		
	print("uhhhh ", get_viewport().get_mouse_position(), " ", Input.mouse_mode, " ", rotating, " ")
	
func _input(event):
	if rotating and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * cam_sens
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - (event.relative.y * cam_sens), min_cam_rot, max_cam_rot)
