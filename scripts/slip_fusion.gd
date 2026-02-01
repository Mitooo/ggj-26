extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionShape2D
@onready var slip_sprite: Sprite2D = $SlipPlaceholder

var slip_1 = Rect2(774, 703, 490, 312)
var slip_2 = Rect2(1391, 684, 490, 311)
var slip_3 = Rect2(110, 1218, 491, 312)
var slip_4 = Rect2(774, 1208, 490, 311)
var slip_5 = Rect2(132, 1655, 490, 311)
var slip_6 = Rect2(769, 1648, 490, 311)
var slip_7 = Rect2(1341, 1651, 490, 311)
var slip_8 = Rect2(122, 2158, 490, 311)
var slip_texture_regions = [slip_1, slip_2, slip_3, slip_4, slip_5, slip_6, slip_7, slip_8]

var is_attracted_by_magneto: bool = false
var target
var attraction_duration: float = 2.0
var attraction_timer: float = 0.0

func _ready() -> void:
	var atlas := slip_sprite.texture
	atlas = atlas.duplicate(true)
	atlas.resource_local_to_scene = true
	slip_sprite.texture = atlas
	slip_sprite.texture.region = slip_texture_regions.pick_random()

	scale = Vector2.ONE * randf_range(0.5, 1.2)

func _process(delta: float) -> void:
	if is_attracted_by_magneto and target != null:
		var direction = (target.global_position - global_position).normalized()
		var speed := 500.0
		position += direction * speed * delta
		attraction_timer += delta
		if attraction_timer >= attraction_duration:
			is_attracted_by_magneto = false
			attraction_timer = 0.0
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_sound_effect("slip_froisse")
		GameManager.fuse_slip_with_player(self, collision_polygon, slip_sprite)
		queue_free()

func attracted_by_magneto()  :
	is_attracted_by_magneto = true
	target = GameManager.player_instance
