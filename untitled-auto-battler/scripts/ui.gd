extends Node

@onready var toggle_music_button: Button = %ToggleMusicButton
@onready var fps_label: Label = %FPS_Label

const MUSIC_ON = preload("res://images/music_on.png")
const MUSIC_OFF = preload("res://images/music_off.png")

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_toggle_music_button_pressed() -> void:
	SoundManager.toggle_music()
	if %ToggleMusicButton.icon == MUSIC_ON:
		%ToggleMusicButton.icon = MUSIC_OFF
	else:
		%ToggleMusicButton.icon = MUSIC_ON
