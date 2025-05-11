extends Node

@onready var player_units: Node = %PlayerUnits
@onready var enemy_units: Node = %EnemyUnits

var combat_in_progress: bool = false

var num_player_units
var num_enemy_units

signal get_random_team_requested

func _ready() -> void:
	get_random_team_requested.connect(DataManager._on_get_random_team_requested)
	DataManager.combat_team_received.connect(_on_combat_team_received)
	
	get_random_team_requested.emit()

func _process(_delta: float) -> void:
	if (combat_in_progress):
		if (num_player_units == 0 or num_enemy_units == 0):
			end_combat()

func start_combat():
	combat_in_progress = true
	num_player_units = player_units.get_children().size()
	num_enemy_units = enemy_units.get_children().size()
	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.enable_combat()
		unit.unit_died.connect(_on_unit_died)

func end_combat():
	get_random_team_requested.disconnect(DataManager._on_get_random_team_requested)
	DataManager.combat_team_received.disconnect(_on_combat_team_received)
	combat_in_progress = false
	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.disable_combat()
		if unit.unit_died.is_connected(_on_unit_died):
			unit.unit_died.disconnect(_on_unit_died)

func _on_unit_died(_unit: Unit, team: String) -> void:
	if (team == "PLAYER"): num_player_units -= 1
	if (team == "ENEMY"): num_enemy_units -= 1

func _on_end_combat_button_pressed() -> void:
	end_combat()
	GameManager.change_to_prep_scene()

func _on_combat_team_received(unit_array) -> void:
	GameManager.construct_enemy_team(unit_array, %EnemyHexes.get_children(), %EnemyUnits)
	GameManager.construct_player_team(%PlayerHexes.get_children(), %PlayerUnits)
	start_combat()
