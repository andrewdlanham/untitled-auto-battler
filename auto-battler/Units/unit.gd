extends Node3D
class_name Unit

@onready var health_label: Label3D = $HealthLabel
var current_hex : Hex

@export var unit_name : String
@export var cost : int = 1
@export var rarity : int = 1

# Combat stats
@export var health : float = 100.00
@export var armor : float = 10.00
@export var magic_resistance : float = 10.00
@export var attack_damage : float = 10.00
@export var magic_damage : float = 10.00
@export var attack_range : int = 1
@export var attack_speed : float = 1.00

# Signals
# TODO: Implement hex_change_attempted signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_label.text = str(health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
