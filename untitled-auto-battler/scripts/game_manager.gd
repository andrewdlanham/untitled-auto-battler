extends Node

var unit_cap_by_round: Array = [
	{ "rounds": range(1, 4), "cap": 3 },	# Rounds 1-3
	{ "rounds": range(4, 6), "cap": 4 },	# Rounds 4-5
	{ "rounds": range(6, 8), "cap": 5 },	# Rounds 6-7
	{ "rounds": range(8, 10), "cap": 6 },	# Rounds 8-9
	{ "rounds": range(10, 16), "cap": 7 }	# Rounds 10-15
]

const prep_scene_resource = preload("res://scenes/prep_scene.tscn")
const combat_scene_resource = preload("res://scenes/combat_scene.tscn")
const menu_scene_resource = preload("res://scenes/menu.tscn")

var player_units: Array = []

var preparation_scene: Node3D
var player_units_node: Node
var player_hexes_node: Node

var current_round: int
var round_label: Label

var active_scene

func _ready() -> void:
	var cursor = load("res://assets/images/cursors/point.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW)

	active_scene = get_tree().root.get_node("Auth")

func start_game() -> void:

	current_round = 1

	remove_active_scene()
	preparation_scene = prep_scene_resource.instantiate()
	get_tree().root.add_child(preparation_scene)
	active_scene = preparation_scene

	SoundManager.play_music("prep_scene_music")

func change_to_menu_scene() -> void:
	remove_active_scene()
	var menu_scene = menu_scene_resource.instantiate()
	get_tree().root.add_child(menu_scene)
	active_scene = menu_scene

func change_to_combat_scene() -> void:

	prepare_units_for_scene_transition("COMBAT")

	remove_active_scene()

	var combat_scene = combat_scene_resource.instantiate()
	get_tree().root.add_child(combat_scene)

	active_scene = combat_scene

	SoundManager.play_music("combat_scene_music")

func change_to_prep_scene() -> void:
	prepare_units_for_scene_transition("PREP")

	remove_active_scene()

	get_tree().root.add_child(preparation_scene)

	current_round += 1
	update_round_label()

	construct_player_team(player_hexes_node.get_children(), player_units_node)
	preparation_scene.start_new_round()

	active_scene = preparation_scene

	SoundManager.play_music("prep_scene_music")

func construct_player_team(target_hexes, parent_node) -> void:
	for unit in player_units:
		for hex in target_hexes:
			if hex.hex_id == unit.connection_hex_id:
				parent_node.add_child(unit)
				unit.try_connect_to_hex(hex)

func construct_enemy_team(unit_array, hexes, enemy_units_node) -> void:
	for unit: Dictionary in unit_array:
		var unit_scene = load(UnitRegistry.get_scene_path(unit.unit_id))
		var new_unit: Unit = unit_scene.instantiate()
		new_unit.level = unit["level"]
		for hex in hexes:
			if hex.hex_id == unit["hex_id"]:
				enemy_units_node.add_child(new_unit)
				new_unit.try_connect_to_hex(hex)
				new_unit.team = "ENEMY"
				new_unit.apply_level_properties()

func prepare_units_for_scene_transition(destination_scene) -> void:

	var current_player_units
	if destination_scene == "PREP":
		current_player_units = active_scene.get_node("PlayerUnits").get_children()

	elif destination_scene == "COMBAT":
		current_player_units = player_units_node.get_children()
	
	player_units = []
	for unit in current_player_units:
		
		if destination_scene == "COMBAT": 
			unit.connection_hex_id = unit.current_hex_id

		unit.reset()

		unit.current_hex.unit_on_hex = null
		unit.current_hex = null
		unit.current_hex_id = null
		unit.target_enemy = null
		unit.get_parent().remove_child(unit)
		player_units.append(unit)

func get_player_unit_info() -> Array:
	var unit_info_array = []
	for unit: Unit in player_units_node.get_children():
		unit_info_array.append(unit.get_info_dict())
	return unit_info_array

func update_round_label() -> void:
	round_label.text = "Round" + "\n" + str(current_round) + " / 15"

func get_unit_cap(round_num: int) -> int:
	for entry: Dictionary in unit_cap_by_round:
		if round_num in entry["rounds"]:
			return entry["cap"]
	return 7 	# Default if no match found, but this should not occur

func get_current_unit_cap() -> int:
	return get_unit_cap(current_round)

func is_active_units_full() -> bool:
	return player_units_node.get_children().size() >= get_current_unit_cap()

func remove_active_scene() -> void:
	get_tree().root.remove_child(active_scene)
