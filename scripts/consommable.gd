extends Area2D

var slip_type: int = GameManager.SlipType.SLIP_KANGOUROU # Type de slip, à définir
@onready var sprite: Sprite2D = $SlipPlaceholder

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

			GameManager.SlipType.SLIP_KANGOUROU:
				body.increase_jump_count()

			GameManager.SlipType.SLIP_VISION:
				body.set_blur(true)
				body.restart_timer()

			GameManager.SlipType.BOMBO_SLIP:
				print("Effet du BOMBO_SLIP appliqué au joueur")
				
			GameManager.SlipType.MAGNETO_SLIP:
				print("Effet du MAGNETO_SLIP appliqué au joueur")
		queue_free()
