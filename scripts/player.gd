extends RigidBody2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var action_audio_player: AudioStreamPlayer2D = $AudioActionPlayer

@onready var dash_sound_01: AudioStream = preload("res://assets/sounds/prouts/prout_mains_01.mp3")
@onready var dash_sound_02: AudioStream = preload("res://assets/sounds/prouts/prout_mains_02.mp3")
@onready var dash_sound_03: AudioStream = preload("res://assets/sounds/prouts/prout_mains_03.mp3")
@onready var dash_sound_04: AudioStream = preload("res://assets/sounds/prouts/prout_mains_04.mp3")
@onready var dash_sounds: Array = [dash_sound_01, dash_sound_02, dash_sound_03, dash_sound_04]

@onready var jump_sound: AudioStream = preload("res://assets/sounds/saut/zboing_02.mp3")

@onready var sample_texture := $CanvasLayer/MarginContainer/HBoxContainer/Sample
@onready var ui_jump_container: HBoxContainer = $CanvasLayer/MarginContainer/HBoxContainer

@onready var state_face: TextureRect = $CanvasLayer/MarginContainer/StateFace
var face_normal_rect: Rect2 = Rect2(323, 55, 655, 873)
var face_happy_rect: Rect2 = Rect2(997, 56, 655, 872)
var face_angry_rect: Rect2 = Rect2(1716, 77, 655, 870)
var face_dead_rect: Rect2 = Rect2(2432, 83, 655, 873)

@onready var blur_rect: ColorRect = $ColorRect
@onready var effect_timer: Timer = $Effect

var fart_ui_counter_list = []

var fart_counter: int = 0
var jump_count: int = 0
var death_countdown: float = 2.5

var score: int = 200

signal player_died

func _ready() -> void:
	reset_fart_counter()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("terrain"):
		audio_player.play()

func _process(delta: float) -> void:
	# Vérifier si le joueur est au sol pour compter le décompte de defaite
	if linear_velocity.y <= 0.5 and linear_velocity.y >= -0.5:
		death_countdown -= delta
		if death_countdown <= 0:
			print("Le joueur est mort.")
			player_died.emit()
	else:
		death_countdown = 2.5  # Réinitialiser le décompte si le joueur n'est pas au sol

func _input(event):
	# Mouvement de droite à gauche
	if event.is_action_pressed("ui_right") and fart_counter > 0:
		use_fart()
		linear_velocity.x += 400
	if event.is_action_pressed("ui_left") and fart_counter > 0:
		use_fart()
		linear_velocity.x -= 400
	if event.is_action_pressed("ui_accept") and jump_count > 0:
		print("Jump!")
		jump()
	
func set_blur(blurred: bool) -> void:
	blur_rect.visible = blurred

func restart_timer() -> void:
	effect_timer.start()

func _on_effect_timeout() -> void:
	set_blur(false)

func reset_fart_counter() -> void:
	for ui_element in fart_ui_counter_list:
		ui_element.queue_free()
	fart_ui_counter_list.clear()
	
	fart_counter = 7
	for i in range(fart_counter):
		var ui_element = sample_texture.duplicate()
		ui_element.visible = true
		ui_jump_container.add_child(ui_element)
		fart_ui_counter_list.append(ui_element)

func jump() -> void:
	apply_impulse(Vector2(0, -2500), Vector2.ZERO)
	jump_count -= 1
	action_audio_player.stream = jump_sound
	action_audio_player.play()

func increase_jump_count() -> void:
	jump_count += 1

func use_fart() -> void:
	fart_counter -= 1
	action_audio_player.stream = dash_sounds.pick_random()
	action_audio_player.play()
	fart_ui_counter_list[fart_counter].queue_free()
	fart_ui_counter_list.remove_at(fart_counter)
