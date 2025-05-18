extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var name_label = %NameLabel
@onready var level_label = %LevelLabel
@onready var health_label = %HealthLabel
@onready var attack_damage_label = %AttackDamageLabel
@onready var attack_speed_label = %AttackSpeedLabel

func _ready() -> void:
	canvas_layer.visible = false

func show_stats(unit):
	name_label.text = "Name: " + unit.unit_name
	level_label.text = "Level: " + str(unit.level)
	health_label.text = "HP: " + str(unit.health)
	attack_damage_label.text = "Attack: " + str(unit.attack_damage)
	attack_speed_label.text = "Attack Speed: " + str(unit.attack_speed)
	
	canvas_layer.visible = true

func hide_stats():
	canvas_layer.visible = false
