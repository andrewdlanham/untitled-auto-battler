extends Node3D
class_name Unit

@onready var health_label: Label3D = $HealthLabel
var current_hex : Hex

@export var unit_name : String
@export var cost : int = 1


# Combat stats
@export var health : float = 100.00

# Signals
# TODO: Implement hex_change_attempted signal

# Called when the node enters the scene tree for the first time.
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
