extends Node

var possible_units = [
	load(UnitRegistry.get_scene_path("unit_archer"))
]

signal shop_roll_requested

func _ready() -> void:
	_connect_signals()
	
func _connect_signals() -> void:
	%GoldManager.shop_roll_approved.connect(_on_roll_shop_approved)

#region -- Signal Handlers --
func _on_roll_shop_pressed() -> void:
	shop_roll_requested.emit()

func _on_roll_shop_approved() -> void:
	# TODO: Add unit freezing logic
	for shop_hex in %ShopHexes.get_children():
		# Remove previous unit if needed
		if shop_hex.unit_on_hex != null:
			shop_hex.unit_on_hex.remove_self()
		# Add new random unit
		var rng = RandomNumberGenerator.new()
		var random_unit_index = rng.randi_range(0, possible_units.size() - 1)
		var new_unit = possible_units[random_unit_index].instantiate()
		new_unit.position = shop_hex.snap_point.global_position
		shop_hex.unit_on_hex = new_unit
		new_unit.current_hex = shop_hex
		%ShopUnits.add_child(new_unit)
#endregion
