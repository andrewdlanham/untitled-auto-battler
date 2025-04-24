# TODO: Upgrade unit stats on level-up

extends Node3D

class_name Unit

@onready var health_label: Label3D = $HealthLabel
@onready var level_label: Label3D = $LevelLabel

@export var unit_name : String
@export var unit_id : String

@export var cost : int = 1
@export var level : int = 1

var current_hex : Hex

# Combat stats
@export var health : float = 100.00

func _ready() -> void:
	update_health_label_text()
	update_level_label_text()

#region -- Helpers --
func update_health_label_text() -> void:
	health_label.text = str(health)

func update_level_label_text() -> void:
	level_label.text = "LVL " + str(level)

func add_health(amount) -> void:
	health += amount
	update_health_label_text()

func subtract_health(amount) -> void:
	health -= amount
	update_health_label_text()

func level_up() -> void:
	level += 1
	update_level_label_text()

func get_info_dict() -> Dictionary:
	return {
		"unit_name" : self.unit_name,
		"unit_id" : self.unit_id,
		"hex_id" : self.current_hex.hex_id,
		"level" : self.level,
		"cost" : self.cost
		}
#endregion
