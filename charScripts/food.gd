extends RigidBody3D

@export var value: int = 1

func on_clicked() -> void:
	print("clicked!")

func consumed(consumer: Object) -> void:
	print("consumed!")
	if consumer.has_method("health_modify"):
		consumer.health_modify(value)
	queue_free()
