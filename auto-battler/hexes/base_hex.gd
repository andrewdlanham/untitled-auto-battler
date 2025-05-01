extends Node3D

class_name Hex

@onready var snap_point: Node3D = $SnapPoint
@onready var hex_mesh: MeshInstance3D = $HexMesh

@export var hex_id: String
@export var hex_type: String
@export var unit_on_hex: Unit
@export var neighbors: Array[Node3D]


func free_unit_on_hex() -> void:
	if unit_on_hex != null: unit_on_hex.queue_free()
	unit_on_hex = null

func is_occupied() -> bool:
	return unit_on_hex != null
