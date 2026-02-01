extends Area2D

@export var force: float =  10.0
var force_direction: Vector2 

var debug_bumper_position : Vector2 = Vector2.ZERO
var debug_force_direction : Vector2 = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	force_direction = body.get_position() - get_position()
	
	if body.is_in_group("player"):
		body.apply_central_impulse(Vector2(force_direction * force))
		
	$AudioStreamPlayer.pitch_scale = randf_range(0.8,1.2)
	$AudioStreamPlayer.play()
