extends Node3D
class_name Unit

@export var unit_name : String
@export var health : float = 100.00
@export var cost : int = 1
@export var rarity : int = 1
@onready var health_label: Label3D = $HealthLabel

var current_hex : Hex

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_label.text = str(health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
