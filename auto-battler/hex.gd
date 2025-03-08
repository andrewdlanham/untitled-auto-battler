extends Node3D
class_name Hex

@onready var snap_point: Node3D = $"Snap Point"
var unit_on_hex : Unit
@export var hex_id : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func free_unit_on_hex():
	if unit_on_hex != null: unit_on_hex.queue_free()
	
