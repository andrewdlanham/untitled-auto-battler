extends Node3D

class_name Hex

@onready var snap_point: Node3D = $"Snap Point"
@export var hex_id : String
@export var hex_type : String
@export var unit_on_hex : Unit

#region -- Helpers --
func free_unit_on_hex() -> void:
	if unit_on_hex != null: unit_on_hex.queue_free()
	unit_on_hex = null
#endregion
