extends Node

const UNIT_SCENE_PATHS = {
	"base_unit" : "res://units/base_unit.tscn",
	# Common Units
	"unit_archer" : "res://units/common/archer/archer.tscn",
	"unit_warrior" : "res://units/common/warrior/warrior.tscn",
	"unit_knight" : "res://units/common/knight/knight.tscn",
	# Uncommon Units
	"unit_paladin" : "res://units/uncommon/paladin/paladin.tscn",
	"unit_witch" : "res://units/uncommon/witch/witch.tscn",
	"unit_rogue" : "res://units/uncommon/rogue/rogue.tscn",
	# Rare Units
	"unit_wizard" : "res://units/rare/wizard/wizard.tscn",
}

func get_scene_path(unit_id: String) -> String:
	return UNIT_SCENE_PATHS.get(unit_id, "")
