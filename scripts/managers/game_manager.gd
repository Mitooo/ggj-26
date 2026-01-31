extends Node

@onready var player_scene = preload("res://scenes/elements/player.tscn")

func load_game():
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.position = Vector2(945, -5745)  # Set initial position based on game_scene.tscn
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# quitte le jeu
		get_tree().quit()
