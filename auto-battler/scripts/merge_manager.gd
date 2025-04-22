extends Node

func _ready() -> void:
	%DragDropManager.new_unit_placed.connect(_on_new_unit_placed)

func handle_unit_merging(match_name: String) -> void:
	var matching_units = []
	for unit in %PlayerUnits.get_children():
		if unit.unit_name == match_name:
			matching_units.append(unit)
	if matching_units.size() == 3:
		matching_units[0].free()
		matching_units[1].free()
		matching_units[2].level += 1

#region -- Signal Handlers --
func _on_new_unit_placed(unit: Unit) -> void:
	handle_unit_merging(unit.unit_name)
#endregion
