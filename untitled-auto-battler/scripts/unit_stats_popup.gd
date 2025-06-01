extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var name_label = %NameLabel
@onready var level_label = %LevelLabel
@onready var health_label = %HealthLabel
@onready var attack_damage_label = %AttackDamageLabel
@onready var attack_speed_label = %AttackSpeedLabel
@onready var freeze_unit_button: Button = %FreezeUnitButton

var selected_unit: Unit

func _ready() -> void:
	canvas_layer.visible = false
	%GoldManager.unit_sold.connect(_on_unit_sold)

func show_stats(unit: Unit) -> void:
	selected_unit = unit
	name_label.text = unit.unit_name
	level_label.text = "Level: " + str(unit.level)
	health_label.text = "HP: " + str(unit.health)
	attack_damage_label.text = "Attack: " + str(unit.attack_damage)
	attack_speed_label.text = "Attack Speed: " + str(snapped(unit.attack_speed, 0.1)) + " APS"
	
	canvas_layer.visible = true
	
	_set_freeze_button_visibility(unit)

func hide_stats() -> void:
	canvas_layer.visible = false
	selected_unit = null

func _set_freeze_button_visibility(unit: Unit) -> void:
	if (unit.team == "PLAYER"):
		freeze_unit_button.visible = false
	else:
		freeze_unit_button.visible = true

func _on_freeze_unit_button_pressed() -> void:
	if (selected_unit.is_frozen):
		selected_unit.unfreeze()
	else:
		selected_unit.freeze()

func _on_unit_sold() -> void:
	hide_stats()
