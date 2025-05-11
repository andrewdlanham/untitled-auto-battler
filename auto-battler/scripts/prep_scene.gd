extends Node3D

func _ready() -> void:
	GameManager.player_units_node = %PlayerUnits
	GameManager.player_hexes_node = %PlayerHexes
