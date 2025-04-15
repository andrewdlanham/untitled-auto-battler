extends Node3D

class_name Hex

@onready var snap_point: Node3D = $"Snap Point"
@export var hex_id : String
@export var hex_type : String
var unit_on_hex : Unit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func free_unit_on_hex():
	if unit_on_hex != null: unit_on_hex.queue_free()
	
