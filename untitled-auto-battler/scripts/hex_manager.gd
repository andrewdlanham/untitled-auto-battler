extends Node

func _ready() -> void:
	_connect_all_hexes()

func _connect_all_hexes() -> void:
	var all_hexes = %PlayerHexes.get_children() + %EnemyHexes.get_children() + %NeutralHexes.get_children()
	for hex in all_hexes:
		hex.connect_to_neighbor_hexes(all_hexes)
