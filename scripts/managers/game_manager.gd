extends Node

@onready var player_scene = preload("res://scenes/elements/player.tscn")
@onready var slip_power_scene = preload("res://scenes/slip.tscn")
@onready var slip_scene = preload("res://scenes/elements/slip_fusion.tscn")

var initial_player_position = Vector2(945, -5745)
var slip_positions = []  # Positions où les slips seront placés
var player_instance: Node = null
var polygon_triangles: PackedInt32Array = PackedInt32Array()
var current_slip_spawn_area: Polygon2D = null

signal slip_fusion

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

	player_instance.position = initial_player_position  # Set initial position
	player_instance.call_deferred("init_player_values")
	
	slip_positions.clear()
	if slip_spawn_area != null:
		if polygon_triangles.size() == 0:
			polygon_triangles = Geometry2D.triangulate_polygon(slip_spawn_area.polygon)
		current_slip_spawn_area = slip_spawn_area

	# charger les slips dans les triangles du polygon de spawn
	var triangle_count := int(polygon_triangles.size() / 3)
	for tri_index in range(triangle_count):
		var base := tri_index * 3
		var idx0 := polygon_triangles[base + 0]
		var idx1 := polygon_triangles[base + 1]
		var idx2 := polygon_triangles[base + 2]
		var v0 := current_slip_spawn_area.to_global(current_slip_spawn_area.polygon[idx0])
		var v1 := current_slip_spawn_area.to_global(current_slip_spawn_area.polygon[idx1])
		var v2 := current_slip_spawn_area.to_global(current_slip_spawn_area.polygon[idx2])
		var slip_position := random_point_in_triangle(v0, v1, v2)
		slip_positions.append(slip_position)

	for slip_position in slip_positions:
		if randi() % 10 < 7 :
			instanciate_slip_at_position(slip_position)
		else:
			instantiate_slip_power(slip_position)

func instanciate_slip_at_position(position: Vector2) -> void:
	var slip_instance = slip_scene.instantiate().duplicate()
	add_child(slip_instance)
	slip_instance.position = position
	slip_instance.rotation_degrees = randf() * 360.0

func instantiate_slip_power(position: Vector2) -> void:
	var slip_power_instance = slip_power_scene.instantiate().duplicate()
	add_child(slip_power_instance)
	slip_power_instance.position = position
	var slip_type_rnd = randi() % 5
	slip_power_instance.call_deferred("update_slip_type", slip_type_rnd)

func fusion_polygon_with_player(slip_polygon) -> void:
	if player_instance != null:
		var new_poly
		var player_polygon: CollisionPolygon2D = player_instance.polygon
		var merged_polygon = Geometry2D.merge_polygons(player_polygon.polygon, slip_polygon)
		if merged_polygon.size() == 1 and not Geometry2D.is_polygon_clockwise(merged_polygon[0]):
			new_poly = merged_polygon[0]
		player_instance.update_poly(new_poly)

func fuse_slip_with_player(slip_node: Node2D, slip_collider: CollisionPolygon2D, slip_sprite: Sprite2D = null) -> void:
	slip_fusion.emit()
	var player_collider: CollisionPolygon2D = player_instance.polygon

	# IMPORTANT: Geometry2D.merge_polygons() requires both polygons in the same coordinate space.
	# We convert the slip collider points (local to slip_collider) -> global -> local to player_collider.
	var slip_poly_player_local := PackedVector2Array()
	for p in slip_collider.polygon:
		var p_global := slip_collider.to_global(p)
		slip_poly_player_local.append(player_collider.to_local(p_global))

	var merged := Geometry2D.merge_polygons(player_collider.polygon, slip_poly_player_local)
	var chosen := _pick_largest_polygon(merged)
	if Geometry2D.is_polygon_clockwise(chosen):
		chosen.reverse()
	player_instance.call_deferred("update_poly", merged[0])

	# Attache le visuel du slip au joueur
	if slip_sprite != null:
		var attached := slip_sprite.duplicate()
		player_instance.sprite_container.add_child(attached)
		if attached is Node2D:
			attached.global_transform = slip_sprite.global_transform

	slip_node.queue_free()

func _pick_largest_polygon(polygons: Array) -> PackedVector2Array:
	var best: PackedVector2Array = PackedVector2Array()
	var best_area := -1.0
	for poly in polygons:
		if poly is PackedVector2Array:
			var area := _polygon_area_abs(poly)
			if area > best_area:
				best_area = area
				best = poly
	return best

func _polygon_area_abs(poly: PackedVector2Array) -> float:
	# Shoelace formula. Returns absolute area.
	var n := poly.size()
	if n < 3:
		return 0.0
	var sum := 0.0
	for i in range(n):
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		sum += (a.x * b.y) - (b.x * a.y)
	return abs(sum) * 0.5

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
