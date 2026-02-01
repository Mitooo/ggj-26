extends Node2D

@onready var slip_spawn: Polygon2D = $SlipSpawnArea

func _ready() -> void:
	GameManager.load_game(slip_spawn)
