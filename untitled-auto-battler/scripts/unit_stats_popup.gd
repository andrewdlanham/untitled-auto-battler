extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var name_label = %NameLabel
@onready var level_label = %LevelLabel
@onready var health_label = %HealthLabel
@onready var attack_damage_label = %AttackDamageLabel
@onready var attack_speed_label = %AttackSpeedLabel
@onready var freeze_unit_button: Button = %FreezeUnitButton
@onready var sell_unit_button: Button = %SellUnitButton

signal unit_sold

var selected_unit: Unit

func _ready() -> void:
	canvas_layer.visible = false
	freeze_unit_button.visible = false
	sell_unit_button.visible = false

func show_stats(unit: Unit) -> void:
	selected_unit = unit
	var starString = ""
	for i in range(0, unit.level):
		starString += "⭐"
	name_label.text = unit.unit_name
	level_label.text = starString
	health_label.text = str(unit.health)
	attack_damage_label.text = str(unit.attack_damage)
	attack_speed_label.text = str(snapped(unit.attack_speed, 0.1)) + " APS"
	
	canvas_layer.visible = true
	
	_set_freeze_button_visibility(unit)
	_set_sell_button_visibility(unit)

func hide_stats() -> void:
	canvas_layer.visible = false
	selected_unit = null

func _set_freeze_button_visibility(unit: Unit) -> void:
	if (unit.team == "PLAYER"):
		freeze_unit_button.visible = false
	else:
		freeze_unit_button.visible = true

func _set_sell_button_visibility(unit: Unit) -> void:
	if (unit.current_hex.is_shop_hex()):
		sell_unit_button.visible = false
	else:
		sell_unit_button.visible = true

func _on_freeze_unit_button_pressed() -> void:
	if (selected_unit.is_frozen):
		selected_unit.unfreeze()
	else:
		selected_unit.freeze()

func _on_sell_unit_button_pressed() -> void:
	if (selected_unit == null):
		return
	# Refund gold based on the unit's level
	match selected_unit.level:
		1: %GoldManager.add_gold(1)
		2: %GoldManager.add_gold(3)
		3: %GoldManager.add_gold(5)
	selected_unit.remove_self()
	unit_sold.emit()
	hide_stats()
