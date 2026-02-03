extends Node

@onready var sfx_player := AudioStreamPlayer.new()
@onready var music_player := AudioStreamPlayer.new()

var sfx: Dictionary = {}
var music_tracks: Dictionary = {}
var current_track: String = ""

func _ready() -> void:
	add_child(sfx_player)
	add_child(music_player)

	# Route players to buses
	sfx_player.bus = "SFX"
	music_player.bus = "Music"

	music_player.volume_db = -10

	sfx["roll_shop"] = preload("res://assets/sounds/roll_shop.ogg")
	sfx["unit_placed"] = preload("res://assets/sounds/unit_placed.ogg")
	sfx["button_click"] = preload("res://assets/sounds/button_click.wav")

	music_tracks["prep_scene_music"] = preload("res://assets/sounds/music/prep_scene_music.mp3")
	music_tracks["combat_scene_music"] = preload("res://assets/sounds/music/combat_scene_music.mp3")

func play_sfx(sound_name: String) -> void:
	if sound_name in sfx:
		sfx_player.stream = sfx[sound_name]
		sfx_player.volume_db = -5
		sfx_player.play()

func play_music(track_name: String) -> void:
	if track_name == current_track:
		return

	current_track = track_name
	music_player.stream = music_tracks[track_name]
	music_player.play()

func stop_music() -> void:
	music_player.stop()
	current_track = ""

func toggle_music() -> void:
	var bus := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus, !AudioServer.is_bus_mute(bus))
