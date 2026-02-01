extends Node

@onready var music_menu : AudioStream = preload("res://assets/sounds/music/music_mainmenu.ogg")
@onready var music_game : AudioStream = preload("res://assets/sounds/music/music_game.ogg")
@onready var music_victory : AudioStream = preload("res://assets/sounds/music/music_victory.ogg")
@onready var music_gameover : AudioStream = preload("res://assets/sounds/music/music_gameover.ogg")

const mute_db : float = -80.0 # To mute the audio player
const default_music_db : float = 0.0 # This is for normal volume
const fade_time : float = 1.0 # The time it takes to fade in/out in seconds

var music_player : AudioStreamPlayer = null

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func fade_music_in(track: AudioStream) -> void:
	music_player.stream = track # What what song
	music_player.volume_db = mute_db # Mute the player
	music_player.play() # Start playing
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(music_player, "volume_db", default_music_db, fade_time)
	
func fade_music_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(music_player, "volume_db", mute_db, fade_time)
	
func crossfade_music_to(track: AudioStream) -> void:
	fade_music_out() # Fade out
	fade_music_in(track) # Fade in
