extends Node

@onready var player_units: Node = %PlayerUnits
@onready var enemy_units: Node = %EnemyUnits

var combat_in_progress: bool = false

var num_player_units
var num_enemy_units

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if (combat_in_progress):
		if (num_player_units == 0 or num_enemy_units == 0):
			end_combat()

func start_combat():
	num_player_units = player_units.get_children().size()
	num_enemy_units = enemy_units.get_children().size()
	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.enable_combat()
		unit.unit_died.connect(_on_unit_died)

func end_combat():
	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.disable_combat()

func _on_start_combat_button_pressed() -> void:
	start_combat()

func _on_unit_died(_unit: Unit, team: String) -> void:
	if (team == "PLAYER"): num_player_units -= 1
	if (team == "ENEMY"): num_enemy_units -= 1
