extends Node

@onready var sfx_player = AudioStreamPlayer.new()
@onready var music_player = AudioStreamPlayer.new()

var sfx: Dictionary = {}
var music_tracks: Dictionary = {}

func _ready() -> void:
	add_child(sfx_player)
	add_child(music_player)

	sfx["roll_shop"] = preload("res://assets/sounds/roll_shop.ogg")
	sfx["unit_placed"] = preload("res://assets/sounds/unit_placed.ogg")
	
	music_tracks["prep_scene_music"] = preload("res://assets/sounds/prep_scene_music.mp3")

func play_sfx(sound_name: String) -> void:
	if sound_name in sfx:
		sfx_player.stream = sfx[sound_name]
		sfx_player.volume_db = -5	# Static volumne until sound options are added
		sfx_player.play()
	else:
		print("SFX not found:", name)

func play_music(track_name: String) -> void:
	if track_name in music_tracks:
		music_player.stream = music_tracks[track_name]
		music_player.volume_db = -20	# Static volume until sound options are added
		music_player.play()

func toggle_music() -> void:
	music_player.stream_paused = !music_player.stream_paused
