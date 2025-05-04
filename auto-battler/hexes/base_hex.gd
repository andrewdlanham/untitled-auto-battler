extends Node3D

class_name Hex

@onready var snap_point: Node3D = $SnapPoint
@onready var hex_mesh: MeshInstance3D = $HexMesh

@export var hex_id: String
@export var hex_type: String
@export var unit_on_hex: Unit
@export var neighbors: Array[Node3D]

func _ready() -> void:
	if is_player_hex() or is_enemy_hex():
		_connect_to_neighbor_hexes()

func is_occupied() -> bool:
	return unit_on_hex != null

func is_shop_hex() -> bool:
	return hex_type == "SHOP"

func is_player_hex() -> bool:
	return hex_type == "PLAYER"

func is_enemy_hex() -> bool:
	return hex_type == "ENEMY"

func _connect_to_neighbor_hexes() -> void:
	var possible_neighbor_hexes = get_tree().root.get_node("Game/Hexes/PlayerHexes").get_children() + get_tree().root.get_node("Game/Hexes/EnemyHexes").get_children()
	for hex in possible_neighbor_hexes:
		if hex.name == self.name: continue
		var distance = self.position.distance_to(hex.global_position)
		if distance < 3:	# 3 is a temporary value for the range to check
			neighbors.append(hex)
