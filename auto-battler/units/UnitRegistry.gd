extends Node

const UNIT_SCENE_PATHS = {
	"base_unit" : "res://units/base_unit.tscn",
	"unit_archer" : "res://units/common/archer/archer.tscn",
	"unit_warrior" : "res://units/common/warrior/warrior.tscn",
	"unit_knight" : "res://units/common/knight/knight.tscn",
	"unit_wizard" : "res://units/common/wizard/wizard.tscn",
	"unit_paladin" : "res://units/uncommon/paladin/paladin.tscn",
	"unit_witch" : "res://units/uncommon/witch/witch.tscn"
}

func get_scene_path(unit_id: String) -> String:
	return UNIT_SCENE_PATHS.get(unit_id, "")
