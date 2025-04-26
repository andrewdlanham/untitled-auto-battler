extends Node

@onready var player_units: Node = %PlayerUnits
@onready var enemy_units: Node = %EnemyUnits

var combat_in_progress: bool = false

var num_player_units
var num_enemy_units

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if (combat_in_progress):
		if (num_player_units == 0 or num_enemy_units == 0):
			end_combat()

func start_combat():
	print("Starting combat!")
	num_player_units = player_units.get_children().size()
	num_enemy_units = enemy_units.get_children().size()
	print(num_player_units)
	for unit in player_units.get_children():
		unit.combat_enabled = true
	for unit in enemy_units.get_children():
		unit.combat_enabled = true

func end_combat():
	for unit in player_units.get_children():
		unit.combat_enabled = false
	for unit in enemy_units.get_children():
		unit.combat_enabled = false
	combat_in_progress = false

func _on_start_combat_button_pressed() -> void:
	start_combat()
