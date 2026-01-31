extends RigidBody2D

func _process(_delta: float) -> void:
	# Mouvement de droite à gauche
	if Input.is_action_pressed("ui_right"):
		linear_velocity.x += 10
	if Input.is_action_pressed("ui_left"):
		linear_velocity.x -= 10
	
	# if linear_velocity.x >= 200:
	# 	linear_velocity.x = 200

	# self.linear_velocity = linear_velocity
