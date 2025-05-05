extends Node

const UNIT_SCENE_PATHS = {
	"base_unit" : "res://units/base_unit.tscn",
	"unit_archer" : "res://units/archer.tscn",
	"unit_warrior" : "res://units/warrior.tscn",
}

static func get_scene_path(unit_id: String) -> String:
	return UNIT_SCENE_PATHS.get(unit_id, "")
