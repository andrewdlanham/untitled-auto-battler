extends Node

var possible_units = [
	load(UnitRegistry.get_scene_path("unit_archer"))
]

signal shop_roll_requested

func _ready() -> void:
	_connect_signals()

#region -- Signal Handlers --
func _connect_signals() -> void:
	%GoldManager.shop_roll_approved.connect(_on_roll_shop_approved)

func _on_roll_shop_pressed() -> void:
	shop_roll_requested.emit()

func _on_roll_shop_approved() -> void:
	# TODO: Add unit freezing logic
	for shop_hex in %ShopHexes.get_children():
		# Remove previous unit if needed
		if shop_hex.unit_on_hex != null:
			shop_hex.unit_on_hex.remove_self()

		var new_unit = create_random_unit()
		new_unit.try_connect_to_hex(shop_hex)
		%ShopUnits.add_child(new_unit)
#endregion

func create_random_unit() -> Unit:
	var rng = RandomNumberGenerator.new()
	var random_unit_index = rng.randi_range(0, possible_units.size() - 1)
	var random_unit = possible_units[random_unit_index].instantiate()
	return random_unit
