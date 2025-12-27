extends RigidBody3D

var max_hp: int = 1
var hp: int = max_hp

func on_clicked() -> void:
	print(name + "clicked!")

func health_modify(amount: int) -> void:
	if hp + amount <= max_hp:
		hp += amount
	if hp <= 0:
		queue_free()
