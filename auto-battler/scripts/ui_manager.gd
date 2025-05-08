extends Node

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	%StoreTeamButton.pressed.connect(DataManager._on_store_team_in_db_pressed)

func _on_start_combat_button_pressed() -> void:
	GameManager.change_to_combat_scene()
