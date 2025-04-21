extends Node3D

func _ready() -> void:
	# Notify DataManager that game scene is ready
	DataManager.initialize_game_variables()
