extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%DragDropManager.new_unit_placed.connect(_on_new_unit_placed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_unit_placed(unit: Unit):
	handle_unit_merging(unit.unit_name)
	
func handle_unit_merging(match_name: String):
	var matching_units = []
	for unit in %PlayerUnits.get_children():
		if unit.unit_name == match_name:
			matching_units.append(unit)
	if matching_units.size() == 3:
		matching_units[0].free()
		matching_units[1].free()
		matching_units[2].level += 1
		# TODO: Upgrade unit's stats on level up
