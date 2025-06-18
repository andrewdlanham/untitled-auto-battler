extends Node2D

@onready var logged_in_as_label: Label = $LoggedInAsLabel

func _ready() -> void:
	logged_in_as_label.text = "Logged in as " + DataManager.user_email
	if (DataManager.user_email.contains("guest")):
		logged_in_as_label.text = "Logged in as Guest"

func _on_play_game_button_pressed() -> void:
	print("Starting game...")
	GameManager.start_game()
