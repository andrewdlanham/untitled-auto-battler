extends Node

const UNIT_SCENE_PATHS = {
	"base_unit" : "res://units/base_unit.tscn",
	"unit_archer" : "res://units/common_units/archer/archer.tscn",
	"unit_warrior" : "res://units/common_units/warrior/warrior.tscn",
	"unit_knight" : "res://units/common_units/knight/knight.tscn",
	"unit_wizard" : "res://units/common_units/wizard/wizard.tscn"
}

static func get_scene_path(unit_id: String) -> String:
	return UNIT_SCENE_PATHS.get(unit_id, "")
