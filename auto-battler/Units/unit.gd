extends Node3D

class_name Unit

@onready var health_label: Label3D = $HealthLabel
var current_hex : Hex

@export var unit_name : String
@export var cost : int = 1
@export var level : int = 1

# Combat stats
@export var health : float = 100.00

func _ready() -> void:
	update_health_label_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_health(amount):
	health += amount

func subtract_health(amount):
	health -= amount

func update_health_label_text():
	health_label.text = str(health)

func get_info_dict():
	return {
		"unit_name" : self.unit_name,
		"hex_id" : self.current_hex.hex_id
		}
