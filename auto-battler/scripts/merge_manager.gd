extends Node

const LEVEL_CAP = 3

func _ready() -> void:
	%DragDropManager.new_unit_placed.connect(_on_new_unit_placed)

func handle_unit_merging(match_name: String, match_level: int) -> void:
	if (match_level >= LEVEL_CAP): return	# Don't merge above the level cap
	var matching_units = []
	for unit: Node3D in %PlayerUnits.get_children() + %BenchUnits.get_children():
		if unit.unit_name == match_name and unit.level == match_level:
			matching_units.append(unit)
	if matching_units.size() >= 3:
		merge_units(matching_units)
		handle_unit_merging(match_name, match_level + 1)	# Keep merging if needed
	else:
		return

func merge_units(units) -> void:
	units[0].level_up()
	units[1].remove_self()
	units[2].remove_self()

#region -- Signal Handlers --
func _on_new_unit_placed(unit: Unit) -> void:
	handle_unit_merging(unit.unit_name, unit.level)
#endregion
