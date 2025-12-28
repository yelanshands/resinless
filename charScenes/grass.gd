extends RigidBody3D

var max_hp: int = 1
var hp: int = max_hp
var value: int = 1

func on_clicked() -> void:
	print(name + " clicked!")

func lamb_health_modify(amount: int, from: Node) -> void:
	if from.has_method("enemy_health_modify"):
		if hp + amount <= max_hp:
			hp += amount
		if hp <= 0:
			from.enemy_health_modify(1, self)
			queue_free()
