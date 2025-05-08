extends Node

var player_units = []

var preparation_scene
var combat_scene

func change_to_combat_scene() -> void:
	prepare_units_for_combat_phase()
	
	get_tree().root.remove_child(preparation_scene)
	combat_scene = preload("res://scenes/combat.tscn").instantiate()
	get_tree().root.add_child(combat_scene)

func change_to_prep_scene() -> void:
	prepare_units_for_prep_phase()
	
	get_tree().root.remove_child(combat_scene)
	get_tree().root.add_child(preparation_scene)
	
	construct_player_team(get_tree().root.get_node("Game/Hexes/PlayerHexes").get_children(), get_tree().root.get_node("Game/PlayerUnits"))

func construct_player_team(player_hexes, player_units_node) -> void:
	for unit in player_units:
		for hex in player_hexes:
			if hex.hex_id == unit.connection_hex_id:
				player_units_node.add_child(unit)
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

func prepare_units_for_prep_phase() -> void:
	player_units = []
	var current_player_units = get_tree().root.get_node("CombatScene/PlayerUnits").get_children()
	for unit in current_player_units:
		unit.current_hex.unit_on_hex = null
		unit.current_hex = null
		unit.current_hex_id = null
		unit.target_enemy = null
		unit.get_parent().remove_child(unit)
		player_units.append(unit)

func prepare_units_for_combat_phase() -> void:
	player_units = []
	var current_player_units = get_tree().root.get_node("Game/PlayerUnits").get_children()
	for unit in current_player_units:
		unit.current_hex.unit_on_hex = null
		unit.current_hex = null
		unit.connection_hex_id = unit.current_hex_id
		unit.current_hex_id = null
		unit.target_enemy = null
		unit.get_parent().remove_child(unit)
		player_units.append(unit)
