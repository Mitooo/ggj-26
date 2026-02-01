extends Area2D

var slip_type: int = GameManager.SlipType.SLIP_KANGOUROU # Type de slip, à définir
@onready var sprite: Sprite2D = $SlipPlaceholder
@onready var effect_sprite: Sprite2D = $Effect

func _ready() -> void:
	# Tween pour faire tourner l'effet derrière le slip en continue
	var tween := create_tween()
	tween.set_loops(0)
	tween.tween_property(effect_sprite, "rotation_degrees", 360, 2.0).from(0)

func update_slip_type(new_type: int) -> void:
	slip_type = new_type

	# On duplique pour que le changement de region n'affecte pas tous les consommables.
	var atlas := sprite.texture
	atlas = atlas.duplicate(true)
	atlas.resource_local_to_scene = true
	sprite.texture = atlas
	
	match slip_type:
		GameManager.SlipType.PETO_SLIP:
			sprite.texture.region = Rect2(144, 295, 490, 311)
		GameManager.SlipType.SLIP_KANGOUROU:
			sprite.texture.region = Rect2(1392, 250, 490, 311)
		GameManager.SlipType.SLIP_VISION:
			sprite.texture.region = Rect2(134, 749, 490, 311)
		GameManager.SlipType.BOMBO_SLIP:
			sprite.texture.region = Rect2(1391, 1194, 490, 311)
		GameManager.SlipType.MAGNETO_SLIP:
			sprite.texture.region = Rect2(732, 258, 491, 312)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Appliquer l'effet du slip en fonction de son type
		match slip_type:
			GameManager.SlipType.PETO_SLIP:
				body.reset_fart_counter()
				body.add_sound_effect("slip_froisse")

			GameManager.SlipType.SLIP_KANGOUROU:
				body.increase_jump_count()
				body.add_sound_effect("slip_froisse")

			GameManager.SlipType.SLIP_VISION:
				body.set_blur(true)
				body.restart_timer()
				body.add_sound_effect("slip_froisse")

			GameManager.SlipType.BOMBO_SLIP:
				body.call_deferred("reset_polygon")
				
			GameManager.SlipType.MAGNETO_SLIP:
				body.magneto_pull_around()
		queue_free()
