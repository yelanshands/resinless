extends RigidBody3D
const mutton = preload("uid://bid7f7d5y1s3")

@onready var player: CharacterBody3D = get_parent().get_node("player")
@onready var hitter: Area3D = $hitter
@onready var lunge_cooldown: Timer = $lunge_cooldown
@onready var healthbar: Label3D = $healthbar

@export var max_hp: int = 5
var hp: int = max_hp
@export var speed: float = 0.01
@export var atk_speed: float = 1.0
@export var lunge_cd: float = 3.0
@export var sight_dist: float = 7.0

var drop_y_offset: float = 0.5
var idling: bool = true

func _ready() -> void:
	healthbar.text = "❤︎".repeat(hp)

func _physics_process(_delta: float) -> void:
	var pos = global_position
	var target_pos: Vector3
	var grass: RigidBody3D
	if not is_instance_valid(player):
		#print(get_parent().get_tree_string_pretty())
		player = get_parent().get_node("player")
	var player_pos = player.global_position
	if pos.distance_to(player_pos) <= sight_dist:
		target_pos = player_pos
	if get_parent().has_node("grass"):
		grass = get_parent().get_node("grass")
		var grass_pos = grass.global_position
		if pos.distance_to(grass_pos) <= sight_dist and pos.distance_to(grass_pos) <= pos.distance_to(player_pos):
			target_pos = grass_pos
	if target_pos:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(pos, target_pos, 1, [get_rid()])
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider == player or result.collider == grass:
				idling = false
			else:
				idling = true
		else:
			idling = true
	else:
		idling = true
	
	if hitter.monitoring and abs(linear_velocity.y) <= 0.01:
		hitter.monitoring = false
	
	if not idling:
		global_rotation.x = lerp_angle(global_rotation.x, 0.0, 0.2)
		global_rotation.z = lerp_angle(global_rotation.z, 0.0, 0.2)
		global_rotation.y = lerp_angle(global_rotation.y, -(Vector2(pos.x, pos.z)-Vector2(target_pos.x, target_pos.z)).angle()+0.5*PI, 0.2)
		global_position += -global_transform.basis.z * speed
		if lunge_cooldown.is_stopped():
			hitter.monitoring = true
			apply_central_impulse(Vector3(0.0, 1.5, 0.0))
			apply_central_impulse(-global_transform.basis.z * speed * 500.0)
			lunge_cooldown.start(lunge_cd)

func on_clicked() -> void:
	print(name + " clicked!")
	
func enemy_health_modify(amount: int, _from: Node) -> void:
	if hp + amount <= max_hp:
		hp += amount
	healthbar.text = "❤︎".repeat(hp)
	if hp <= 0:
		die()
		
func die() -> void:
	var mutton_drop = mutton.instantiate()
	get_parent().add_child(mutton_drop)
	mutton_drop.global_position = global_position
	mutton_drop.global_position.y += drop_y_offset
	mutton_drop.apply_central_impulse(Vector3(0.0, 2.5, 0.0))
	queue_free()
	
func _on_hitter_body_entered(body: Node3D) -> void:
	if body.has_method("player_health_modify"):
		print(name, " ", body.name)
		body.player_health_modify(-1, self)
		set_deferred("monitoring", false)
	elif body.has_method("lamb_health_modify"):
		print(name, " ", body.name)
		body.lamb_health_modify(-1, self)
		set_deferred("monitoring", false)
