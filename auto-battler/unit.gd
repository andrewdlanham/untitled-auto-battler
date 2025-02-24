extends Node3D

@export var unit_name : String
@export var health : float = 100.00
@export var cost : int = 1
@onready var health_label: Label3D = $HealthLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_label.text = str(health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
