extends Node

@onready var toggle_music_button: Button = %ToggleMusicButton

const MUSIC_ON = preload("res://images/music_on.png")
const MUSIC_OFF = preload("res://images/music_off.png")

func _on_toggle_music_button_pressed() -> void:
	SoundManager.toggle_music()
	if %ToggleMusicButton.icon == MUSIC_ON:
		%ToggleMusicButton.icon = MUSIC_OFF
	else:
		%ToggleMusicButton.icon = MUSIC_ON
