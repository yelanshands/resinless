extends StaticBody3D

@export var value: int = 1

func on_clicked():
	print("clicked!")

func consumed(consumer: Object):
	print("consumed!")
	if consumer.has_method("health_modify"):
		consumer.health_modify(value)
	queue_free()
