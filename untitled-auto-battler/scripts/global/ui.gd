extends Node

@onready var toggle_music_button: Button = %ToggleMusicButton
@onready var fps_label: Label = %FPS_Label

const MUSIC_ON = preload("res://assets/images/music_on.png")
const MUSIC_OFF = preload("res://assets/images/music_off.png")

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_toggle_music_button_pressed() -> void:
	SoundManager.toggle_music()
	if toggle_music_button.icon == MUSIC_ON:
		toggle_music_button.icon = MUSIC_OFF
	else:
		toggle_music_button.icon = MUSIC_ON

func hide_toggle_music_button() -> void:
	toggle_music_button.visible = false

func unhide_toggle_music_button() -> void:
	toggle_music_button.visible = true
