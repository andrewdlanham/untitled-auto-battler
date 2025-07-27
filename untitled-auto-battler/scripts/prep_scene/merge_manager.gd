extends Node

const LEVEL_CAP = 3
const MERGE_THRESHOLD = 3

signal unit_merge_success

func _ready() -> void:
	%DragDropManager.unit_placed.connect(_on_unit_placed)

func _handle_unit_merging(match_name: String, match_level: int) -> void:
	if (match_level >= LEVEL_CAP): return	# Don't merge above the level cap
	var matching_units = []
	for unit: Node3D in %PlayerUnits.get_children() + %BenchUnits.get_children():
		if unit.unit_name == match_name and unit.level == match_level:
			matching_units.append(unit)
	if matching_units.size() >= MERGE_THRESHOLD:
		_merge_units(matching_units)
		_handle_unit_merging(match_name, match_level + 1)	# Keep merging if needed
	else:
		return

func _merge_units(units) -> void:
	units[0].level_up()
	units[1].remove_self()
	units[2].remove_self()
	unit_merge_success.emit()

func _on_unit_placed() -> void:
	for unit: Unit in %PlayerUnits.get_children() + %BenchUnits.get_children():
		_handle_unit_merging(unit.unit_name, unit.level)

func unit_would_trigger_merge(new_unit: Unit) -> bool:
	var matching_units = []
	for unit: Node3D in %PlayerUnits.get_children() + %BenchUnits.get_children():
		if unit.unit_name == new_unit.unit_name and unit.level == new_unit.level:
			matching_units.append(unit)
	if matching_units.size() >= MERGE_THRESHOLD - 1:
		return true
	else:
		return false
