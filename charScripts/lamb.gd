extends RigidBody3D
const mutton = preload("uid://bid7f7d5y1s3")

@onready var player: CharacterBody3D = get_parent().get_node("player")

@export var max_hp: int = 5
var hp: int = max_hp

var drop_y_offset: float = 0.5
var sight_dist: float = 5.0
var idling: bool = true

func _physics_process(_delta: float) -> void:
	var pos = global_position
	var player_pos = player.global_position
	if pos.distance_to(player_pos) <= sight_dist:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(pos, player_pos, 1, [get_rid()])
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider == player:
				idling = false
				global_rotation.y = lerp_angle(global_rotation.y, -(Vector2(pos.x, pos.z)-Vector2(player_pos.x, player_pos.z)).angle()+0.5*PI, 0.2)
			else:
				#print("1 ", result.collider)
				idling = true
		else:
			#print("2")
			idling = true
	else:
		#print("3")
		idling = true
		
	print(idling)

func on_clicked() -> void:
	print("clicked!")
	
func hit(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()
		
func die() -> void:
	var mutton_drop = mutton.instantiate()
	get_parent().add_child(mutton_drop)
	mutton_drop.global_position = global_position
	mutton_drop.global_position.y += drop_y_offset
	mutton_drop.apply_central_impulse(Vector3(0.0, 2.5, 0.0))
	queue_free()
	
