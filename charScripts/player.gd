extends CharacterBody3D

const PLAYER = preload("uid://btkekl8rpf317")

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var spring_arm_pos: Node3D = $SpringArm3D/Pos
@onready var doodle: Sprite3D = $doodle
@onready var camera: Camera3D = $Camera3D
@onready var collision: CollisionShape3D = $collision
@onready var health: HBoxContainer = $"CanvasLayer/Control/Health"
@onready var hp_texture: TextureRect = $"CanvasLayer/Control/Health/1".duplicate()
@onready var hit: Area3D = $Hit
@onready var hit_window: Timer = $Hit/HitWindow
@onready var weapon: Sprite3D = $doodle/Weapon

@export var max_hp: int = 5
var hp: int = max_hp
@export var speed: float = 5.0
@export var jump_height: float = 5.0
@export var cam_sens: float = 0.004 
@export var drag_sens: float = 0.05
@export var reach: float = 15.0
@export var atk: int = 1
@export var flatten_speed: float = 0.2

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_cam_rot: float = 0.15
var min_cam_rot: float = -0.75
var last_mouse_pos: Vector2 = Vector2.ZERO
var mouse_pos: Vector2 = Vector2.ZERO
var object
var object_distance: float = 0.0
var dragging: bool = false
var rotating: bool = false
var interacting: bool = true
var switch_delay: bool = false
var hps: Array[TextureRect] = []
var flattened: bool = false
var flattened_recovering: int = 0
var prerecover_pos: float
var height: float

func _ready() -> void:
	hps.append($"CanvasLayer/Control/Health/1")
	for i in (max_hp-1):
		hps.append(hp_texture.duplicate())
		health.add_child(hps[i+1])
	height = collision.shape.size.y

func _process(_delta: float) -> void:
	collision.rotation = doodle.rotation
	if flattened_recovering:
		global_position.y = lerp(global_position.y, prerecover_pos + height, flatten_speed*0.75)
		flattened_recovering += 1
		if flattened_recovering >= 10:
			flattened_recovering = 0
	if flattened:
		doodle.global_rotation.x = lerp_angle(doodle.global_rotation.x, -PI/2, flatten_speed)
	else:
		doodle.global_rotation.x = lerp_angle(doodle.global_rotation.x, 0.0, flatten_speed)
		
	if Input.is_action_just_pressed("left_click"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			interacting = false
			get_viewport().set_input_as_handled()
		elif not hit.monitoring:
			hit.monitoring = true
			weapon.rotation_degrees.y = 0.0
			weapon.visible = true
			hit_window.start(0.1)
	if Input.is_action_just_pressed("right_click") and not interacting:
		if not get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			interacting = true
			switch_delay = true
			await get_tree().process_frame
			switch_delay = false
	if hit.monitoring:
		weapon.rotation_degrees.y += 30.0
		
func _physics_process(delta: float) -> void:
	var input = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	var movement_dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if movement_dir:
		var move_angle = lerp_angle(0.0, atan2(movement_dir.x, movement_dir.z), 0.6)
		doodle.rotation.y = lerp_angle(doodle.rotation.y, move_angle, 0.15)
		
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	if Input.is_action_just_pressed("flatten"):
		if flattened:
			prerecover_pos = global_position.y
			flattened_recovering = 1
		flattened = not flattened
	
	camera.global_position = lerp(camera.global_position, spring_arm_pos.global_position, 0.05)
	camera.rotation.x = lerp_angle(camera.rotation.x, spring_arm.rotation.x, 0.05)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_height
		#else:
			#velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	
	move_and_slide()
	
	if (Input.is_action_pressed("right_click") and interacting) or Input.is_action_just_pressed("consume"):
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
			if Input.is_action_just_pressed("consume"):
				if object.has_method("consumed"):
					object.consumed(self)
			elif Input.is_action_pressed("right_click"):
				if object.has_method("on_clicked"):
					object.on_clicked()
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
	
	#if Input.is_action_pressed("right_click"):
		#if not rotating:
			#rotating = true
			#last_mouse_pos = get_viewport().get_mouse_position()
			#print("1 ", get_viewport().get_mouse_position())
			#if not mouse_pos:
				#mouse_pos = last_mouse_pos
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#elif rotating and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#elif rotating and Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		#for i in 2:
			#await get_tree().process_frame
		#Input.warp_mouse(last_mouse_pos)
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#rotating = false
		#print("2 ", get_viewport().get_mouse_position())
		#
	#print("uhhhh ", get_viewport().get_mouse_position(), " ", Input.mouse_mode, " ", rotating, " ")
	
func _input(event) -> void:
	if not switch_delay and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * cam_sens
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - (event.relative.y * cam_sens), min_cam_rot, max_cam_rot)

func health_modify(amount: int) -> void:
	if hp + amount <= max_hp:
		hp += amount
		if amount > 0:
			for i in amount:
				hps[hp-amount+i].visible = true
		elif amount < 0:
			for i in -amount:
				hps[hp-amount-i-1].visible = false
	if hp <= 0:
		var player = PLAYER.instantiate()
		get_parent().add_child(player)
		player.name = "player"
		queue_free()

func _on_hit_window_timeout() -> void:
	hit.monitoring = false
	weapon.visible = false

func _on_hit_body_entered(body: Node3D) -> void:
	print(body)
	if body.has_method("hit"):
		body.hit(atk)
