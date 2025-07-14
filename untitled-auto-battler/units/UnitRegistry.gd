extends Node

const UNIT_SCENE_PATHS = {
	"base_unit" : "res://units/base_unit.tscn",
	# Common Units
	"unit_archer" : "res://units/common/archer/archer.tscn",
	"unit_warrior" : "res://units/common/warrior/warrior.tscn",
	"unit_knight" : "res://units/common/knight/knight.tscn",
	"unit_farmer" : "res://units/common/farmer/farmer.tscn",
	# Uncommon Units
	"unit_paladin" : "res://units/uncommon/paladin/paladin.tscn",
	"unit_wizard" : "res://units/uncommon/wizard/wizard.tscn",
	"unit_brute" : "res://units/uncommon/brute/brute.tscn",
	# Rare Units
	"unit_witch" : "res://units/rare/witch/witch.tscn",
	"unit_rogue" : "res://units/rare/rogue/rogue.tscn",
	"unit_crossbowman" : "res://units/rare/crossbowman/crossbowman.tscn"
}

var unit_stats := {}  # unit_type -> lvl_x -> stat_name -> value

const COLUMN_TYPES = {
	"unit_name": "string",
	"type": "string",
	"att_dmg": "float",
	"att_spd": "float",
	"hp": "float",
	"scale": "float"
}

func _ready() -> void:
	_load_stats_from_csv("res://data/unit-stats.txt")
	print(unit_stats)
	print(get_stat("unit_knight", 2, "hp"))

func _load_stats_from_csv(path: String) -> void:

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		printerr("Failed to open CSV file at: ", path)
		return
	
	var lines: PackedStringArray = file.get_as_text().split("\n", false)

	file.close()
	
	var headers: PackedStringArray = lines[0].strip_edges().split(",")

	# Loop through rows
	for i in range(1, lines.size()):
		var row = lines[i].strip_edges().split(",")
		var unit_id = row[0]
		unit_stats[unit_id] = {}
		
		# Loop through stats for current row
		for j in range(1, row.size()):

			var key = headers[j]

			var parts = key.split("_lvl_")
			if parts.size() != 2:
				continue  # Skip malformed headers

			var stat = parts[0]
			var level_string = "lvl_" + parts[1]

			if !unit_stats[unit_id].has(level_string):
				unit_stats[unit_id][level_string] = {}
			
			var value = row[j]
			var stat_type = COLUMN_TYPES[stat]
			var converted_value = _convert_value(value, stat_type)
			unit_stats[unit_id][level_string][stat] = converted_value

func _convert_value(value: String, value_type: String):
	match value_type:
		"string":
			return value
		"float":
			return float(value)
		"int":
			return int(value)
		"bool":
			return value == "T"
		_:
			return value  # Default

func get_stat(unit_id: String, level: int, stat_name: String):
	var level_string = "lvl_" + str(level)
	if unit_stats.has(unit_id) and unit_stats[unit_id].has(level_string):
		return unit_stats[unit_id][level_string].get(stat_name)
	else:
		return ""

func get_scene_path(unit_id: String) -> String:
	return UNIT_SCENE_PATHS.get(unit_id, "")
