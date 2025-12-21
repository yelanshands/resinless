extends RigidBody3D
const mutton = preload("uid://bid7f7d5y1s3")

@export var max_hp: int = 5
var hp: int = max_hp

var drop_y_offset: float = 0.5

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
	
