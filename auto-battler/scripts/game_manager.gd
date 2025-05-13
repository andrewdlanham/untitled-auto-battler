extends Node

var prep_scene_resource = preload("res://scenes/prep_scene.tscn")
var combat_scene_resource = preload("res://scenes/combat_scene.tscn")

var player_units = []

var preparation_scene
var player_units_node
var player_hexes_node

var combat_scene

func load_prep_scene() -> void:
	preparation_scene = prep_scene_resource.instantiate()
	get_tree().root.add_child(preparation_scene)

func change_to_combat_scene() -> void:
	prepare_units_for_scene_transition("COMBAT")
	
	get_tree().root.remove_child(preparation_scene)
	
	combat_scene = combat_scene_resource.instantiate()
	get_tree().root.add_child(combat_scene)

func change_to_prep_scene() -> void:
	prepare_units_for_scene_transition("PREP")
	
	get_tree().root.remove_child(combat_scene)
	
	get_tree().root.add_child(preparation_scene)
	
	construct_player_team(player_hexes_node.get_children(), player_units_node)

func construct_player_team(target_hexes, parent_node) -> void:
	for unit in player_units:
		for hex in target_hexes:
			if hex.hex_id == unit.connection_hex_id:
				parent_node.add_child(unit)
				unit.try_connect_to_hex(hex)

func construct_enemy_team(unit_array, hexes, enemy_units_node) -> void:
	for unit in unit_array:
		var unit_scene = load(UnitRegistry.get_scene_path(unit.unit_id))
		var new_unit = unit_scene.instantiate()
		for hex in hexes:
			if hex.hex_id == unit["hex_id"]:
				enemy_units_node.add_child(new_unit)
				
				new_unit.try_connect_to_hex(hex)
				new_unit.team = "ENEMY"

func prepare_units_for_scene_transition(destination_scene) -> void:

	var current_player_units
	if destination_scene == "PREP":
		current_player_units = combat_scene.get_node("PlayerUnits").get_children()

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
	for unit in player_units_node.get_children():
		unit_info_array.append(unit.get_info_dict())
	return unit_info_array
