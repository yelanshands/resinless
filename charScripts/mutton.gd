extends RigidBody3D

@export var value: int = 1

func on_clicked() -> void:
	print(name + " clicked!")

func consumed(consumer: Object) -> void:
	print(name + " consumed!")
	if consumer.has_method("player_health_modify"):
		consumer.player_health_modify(value, self)
	queue_free()
