extends Node3D

const lamb = preload("uid://qdcp781qpjee")

@onready var lamb_spawn: Timer = $lambSpawn
@onready var world: Node3D = $world

@export var spawn_cd: float = 5.0
@export var spawn_variation_min: float = 1.0
@export var spawn_variation_max: float = 5.0

func _ready() -> void:
	pass
	
func _on_lamb_spawn_timeout() -> void:
	spawn_lamb(1)

func spawn_lamb(qty: int) -> void:
	for num in qty:
		var lamby = lamb.instantiate()
		add_child(lamby)
	lamb_spawn.start(spawn_cd + randf_range(spawn_variation_min, spawn_variation_max))
