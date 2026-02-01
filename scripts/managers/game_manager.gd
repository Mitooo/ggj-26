extends Node

@onready var player_scene = preload("res://scenes/elements/player.tscn")
@onready var slip_scene = preload("res://scenes/slip.tscn")

var initial_player_position = Vector2(945, -5745)
var slip_positions = []  # Positions où les slips seront placés
var player_instance: Node = null
var polygon_triangles: PackedInt32Array = PackedInt32Array()

# Types de slips
enum SlipType {
	PETO_SLIP,
	SLIP_KANGOUROU,
	SLIP_VISION,
	BOMBO_SLIP,
	MAGNETO_SLIP
}

func load_game(slip_spawn_area: Polygon2D = null) -> void:
	if player_instance == null:
		player_instance = player_scene.instantiate()
		add_child(player_instance)
		player_instance.player_died.connect(_on_player_died)

	player_instance.position = initial_player_position  # Set initial position based on game_scene.tscn
	
	if slip_spawn_area != null:
		if polygon_triangles.size() == 0:
			polygon_triangles = Geometry2D.triangulate_polygon(slip_spawn_area.polygon)

		# charger les slips dans les triangles du polygon de spawn
		var triangle_count := int(polygon_triangles.size() / 3)
		for tri_index in range(triangle_count):
			var base := tri_index * 3
			var idx0 := polygon_triangles[base + 0]
			var idx1 := polygon_triangles[base + 1]
			var idx2 := polygon_triangles[base + 2]
			var v0 := slip_spawn_area.to_global(slip_spawn_area.polygon[idx0])
			var v1 := slip_spawn_area.to_global(slip_spawn_area.polygon[idx1])
			var v2 := slip_spawn_area.to_global(slip_spawn_area.polygon[idx2])
			var slip_position := random_point_in_triangle(v0, v1, v2)
			slip_positions.append(slip_position)

	for slip_position in slip_positions:
		var slip_instance = slip_scene.instantiate().duplicate()
		add_child(slip_instance)
		slip_instance.position = slip_position
		slip_instance.rotation_degrees = randf() * 360.0
		var slip_type_rnd = randi() % 5
		slip_instance.call_deferred("update_slip_type", slip_type_rnd)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# quitte le jeu
		get_tree().quit()

func _on_player_died() -> void:
	load_game()

func random_point_in_triangle(v0: Vector2, v1: Vector2, v2: Vector2) -> Vector2:
	var a = randf()
	var b = randf()
	if a > b:
		var c = b
		b = a
		a = c

	return v0 * a + v1 * (b - a) + v2 * (1 - b)
