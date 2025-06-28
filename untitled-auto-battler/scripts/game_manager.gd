extends Node

var unit_cap_by_round: Array = [
	{ "rounds": range(1, 2), "cap": 2 },	# Round 1
	{ "rounds": range(2, 4), "cap": 3 },	# Rounds 2-3
	{ "rounds": range(4, 6), "cap": 4 },	# Rounds 4-5
	{ "rounds": range(6, 8), "cap": 5 },	# Rounds 6-7
	{ "rounds": range(8, 10), "cap": 6 },	# Rounds 8-9
	{ "rounds": range(10, 16), "cap": 7 }	# Rounds 10-15
]

const WIN_THRESHOLD: int = 10
const MAX_LIVES: int = 5

var player_units: Array = []
var bench_units: Array = []
var shop_units: Array = []

var current_round: int
var number_of_wins: int
var number_of_lives: int

func start_game() -> void:

	current_round = 0
	number_of_wins = 0
	number_of_lives = 5

	SceneManager.switch_to_scene(SceneManager.PREP_SCENE_PATH)
	SoundManager.play_music("prep_scene_music")

func construct_team(unit_info_array, hexes_to_populate, target_parent_node) -> void:
	for unit_info: Dictionary in unit_info_array:
		var unit_scene = load(UnitRegistry.get_scene_path(unit_info.unit_id))
		var new_unit: Unit = unit_scene.instantiate()
		new_unit.level = unit_info["level"]
		for hex in hexes_to_populate:
			if hex.hex_id == unit_info["hex_id"]:
				target_parent_node.add_child(new_unit)
				new_unit.try_connect_to_hex(hex)
				new_unit.apply_level_properties()
				if (target_parent_node.name == "PlayerUnits"):
					new_unit.team = "PLAYER"
				else:
					new_unit.team = "ENEMY"
		if (("frozen" in unit_info) and unit_info["frozen"] == true):
			new_unit.freeze()

func get_unit_cap(round_num: int) -> int:
	for entry: Dictionary in unit_cap_by_round:
		if round_num in entry["rounds"]:
			return entry["cap"]
	return 7 	# Default if no match found, but this should not occur

func get_current_unit_cap() -> int:
	return get_unit_cap(current_round)

func is_active_units_full() -> bool:
	return SceneManager.active_scene.get_node("PlayerUnits").get_children().size() >= get_current_unit_cap()
