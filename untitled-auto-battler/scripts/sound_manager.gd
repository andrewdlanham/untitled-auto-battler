extends Node

@onready var sfx_player = AudioStreamPlayer.new()
@onready var music_player = AudioStreamPlayer.new()

var sfx: Dictionary = {}
var music_tracks: Dictionary = {}
var is_muted: bool = false
var current_track_position: float = 0.0
var current_track: String

func _ready() -> void:
	add_child(sfx_player)
	add_child(music_player)
	music_player.volume_db = -20	# Static volume until sound options are added

	sfx["roll_shop"] = preload("res://assets/sounds/roll_shop.ogg")
	sfx["unit_placed"] = preload("res://assets/sounds/unit_placed.ogg")
	sfx["button_click"] = preload("res://assets/sounds/button_click.wav")
	
	music_tracks["prep_scene_music"] = preload("res://assets/sounds/music/prep_scene_music.mp3")
	music_tracks["combat_scene_music"] = preload("res://assets/sounds/music/combat_scene_music.mp3")

func play_sfx(sound_name: String) -> void:
	if sound_name in sfx:
		sfx_player.stream = sfx[sound_name]
		sfx_player.volume_db = -5	# Static volume until sound options are added
		sfx_player.play()
	else:
		print("SFX not found:", name)

func play_music(track_name: String) -> void:
	music_player.stream = music_tracks[track_name]
	current_track = track_name
	if !is_muted:
		music_player.play(0.0)

func stop_music() -> void:
	music_player.stop()

func toggle_music() -> void:
	is_muted = !is_muted
	if is_muted:
		current_track_position = music_player.get_playback_position()
		music_player.stop()
	if !is_muted:
		music_player.play(current_track_position)
