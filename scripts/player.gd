extends RigidBody2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var dash_sound_01: AudioStream = preload("res://assets/sounds/prouts/prout_mains_01.mp3")
@onready var dash_sound_02: AudioStream = preload("res://assets/sounds/prouts/prout_mains_02.mp3")
@onready var dash_sound_03: AudioStream = preload("res://assets/sounds/prouts/prout_mains_03.mp3")
@onready var dash_sound_04: AudioStream = preload("res://assets/sounds/prouts/prout_mains_04.mp3")
@onready var dash_sounds: Array = [dash_sound_01, dash_sound_02, dash_sound_03, dash_sound_04]

@onready var exploslip_audio: AudioStream = preload("res://assets/sounds/slips/Exploslip.mp3")
@onready var magnetoslip_audio: AudioStream = preload("res://assets/sounds/slips/magnetoslip.mp3")
@onready var slip_froisse_audio: AudioStream = preload("res://assets/sounds/slips/slip_froissé.mp3")

@onready var jump_sound: AudioStream = preload("res://assets/sounds/saut/zboing_02.mp3")

@onready var sample_texture := $CanvasLayer/MarginContainer/HBoxContainer/Sample
@onready var ui_jump_container: HBoxContainer = $CanvasLayer/MarginContainer/HBoxContainer
@onready var sample_kangou_texture := $CanvasLayer/MarginContainer/HBoxKangourou/SampleUiKangourou
@onready var ui_kangou_container: HBoxContainer = $CanvasLayer/MarginContainer/HBoxKangourou

@onready var sprite_container: Node2D = $SpriteContainer
@onready var parachute_sprite: Sprite2D = $Icon/ParachuteSprite
@onready var state_face: TextureRect = $CanvasLayer/MarginContainer/StateFace
@onready var explo_slip_effect: CPUParticles2D = $ExploSlipEffect

var face_normal_rect: Rect2 = Rect2(323, 55, 655, 873)
var face_happy_rect: Rect2 = Rect2(997, 56, 655, 872)
var face_angry_rect: Rect2 = Rect2(1716, 77, 655, 870)
var face_dead_rect: Rect2 = Rect2(2432, 83, 655, 873)

@onready var blur_rect: ColorRect = $ColorRect
@onready var effect_timer: Timer = $Effect
@onready var polygon : CollisionPolygon2D = $Polygon2D

const MAX_SCORE: int = 250
const DEATH_COUNTDOWN_MAX: float = 2
const MAX_FALL_SPEED: int = 1100

var polygon_original: PackedVector2Array = PackedVector2Array()
var fart_ui_counter_list = []
var fart_counter: int = 0
var jump_count: int = 0
var jump_ui_children = []
var death_countdown: float = DEATH_COUNTDOWN_MAX
var score: int = MAX_SCORE

signal player_died

func _ready() -> void:
	init_player_values()
	GameManager.slip_fusion.connect(_on_slip_fusion)
	polygon_original = polygon.polygon.duplicate()

func _on_slip_fusion() -> void:
	score -= 10

	if score <= MAX_SCORE and score > 200:
		state_face.texture.region = face_happy_rect
	elif score <= 200 and score > 150:
		state_face.texture.region = face_normal_rect
	elif score <= 150 and score > 50:
		state_face.texture.region = face_angry_rect
	elif score <= 50:
		state_face.texture.region = face_dead_rect
	
	if score <= 0:
		player_died.emit()

func init_player_values() -> void:
	reset_fart_counter()
	jump_count = 0
	for ui_element in jump_ui_children:
		ui_element.queue_free()
	jump_ui_children.clear()
	death_countdown = DEATH_COUNTDOWN_MAX
	score = MAX_SCORE
	state_face.texture.region = face_happy_rect

func _process(delta: float) -> void:
	# Vérifier si le joueur est au sol pour compter le décompte de defaite
	if linear_velocity.y <= 0.5 and linear_velocity.y >= -0.5:
		death_countdown -= delta
		if death_countdown <= 0:
			player_died.emit()
	else:
		death_countdown = DEATH_COUNTDOWN_MAX  # Réinitialiser le décompte si le joueur n'est pas au sol

	if parachute_sprite.is_visible_in_tree():
		parachute_sprite.global_position = global_position + Vector2.UP * 100
		parachute_sprite.global_rotation = deg_to_rad(180)


func _input(event):
	# Mouvement de droite à gauche
	if event.is_action_pressed("ui_right") and fart_counter > 0:
		use_fart()
		linear_velocity.x += 400
	if event.is_action_pressed("ui_left") and fart_counter > 0:
		use_fart()
		linear_velocity.x -= 400
	if event.is_action_pressed("ui_accept") and jump_count > 0:
		jump()

func _integrate_forces(state):
	var max_fall_speed = MAX_FALL_SPEED
	if parachute_sprite.is_visible_in_tree():
		max_fall_speed = MAX_FALL_SPEED/2

	if state.linear_velocity.length()>max_fall_speed:
		state.linear_velocity=state.linear_velocity.normalized()*max_fall_speed

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
	# gameplay
	apply_impulse(Vector2(0, -2500), Vector2.ZERO)
	jump_count -= 1
	add_sound_effect("jump")
	# ui
	jump_ui_children[jump_ui_children.size()-1].queue_free()
	jump_ui_children.remove_at(jump_ui_children.size()-1)

func increase_jump_count() -> void:
	jump_count += 1
	var ui_element = sample_kangou_texture.duplicate()
	ui_element.visible = true
	ui_kangou_container.add_child(ui_element)
	jump_ui_children.append(ui_element)

func use_fart() -> void:
	fart_counter -= 1
	add_sound_effect("dash")
	fart_ui_counter_list[fart_counter].queue_free()
	fart_ui_counter_list.remove_at(fart_counter)

func update_poly(new_polygon) -> void:
	polygon.polygon = new_polygon

func reset_polygon() -> void:
	add_sound_effect("exploslip")
	score = MAX_SCORE
	state_face.texture.region = face_happy_rect

	polygon.polygon = polygon_original.duplicate()
	
	for child in sprite_container.get_children():
		child.queue_free()

	explo_slip_effect.emitting = true

func magneto_pull_around() -> void:
	add_sound_effect("magnetoslip")
	# attire tous les objets du groupe "fusionnable" autour du joueur
	var pull_radius: float = 1000.0

	var player_global_pos: Vector2 = global_position
	var fusionnables := get_tree().get_nodes_in_group("fusionnable")
	for fusionnable in fusionnables:
		var distance := player_global_pos.distance_to(fusionnable.global_position)
		if distance <= pull_radius:
			fusionnable.attracted_by_magneto()

func add_sound_effect(effect_type: String) -> void:
	var action_audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(action_audio_player)
	action_audio_player.finished.connect(action_audio_player.queue_free)
	action_audio_player.bus = "Effects"
	match effect_type:
		"exploslip":
			action_audio_player.stream = exploslip_audio
		"magnetoslip":
			action_audio_player.stream = magnetoslip_audio
		"slip_froisse":
			action_audio_player.stream = slip_froisse_audio
		"dash":
			action_audio_player.stream = dash_sounds.pick_random()
		"jump":
			action_audio_player.stream = jump_sound
	action_audio_player.play()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("terrain"):
		audio_player.play()

func use_parachute() -> void:
	parachute_sprite.visible = true
	await get_tree().create_timer(2.0).timeout
	parachute_sprite.visible = false
