extends Node

@onready var shop_roll_audio: AudioStreamPlayer = $ShopRollAudio

var common_units: Array[Resource] = [
	
	load(UnitRegistry.get_scene_path("unit_warrior")),
	load(UnitRegistry.get_scene_path("unit_archer")),
	load(UnitRegistry.get_scene_path("unit_knight"))
]

var uncommon_units: Array[Resource] = [
	load(UnitRegistry.get_scene_path("unit_wizard")),
	load(UnitRegistry.get_scene_path("unit_paladin")),
	load(UnitRegistry.get_scene_path("unit_brute"))
]

var rare_units: Array[Resource] = [
	load(UnitRegistry.get_scene_path("unit_witch")),
	load(UnitRegistry.get_scene_path("unit_rogue"))
]

# [common, uncommon, rare]
var shop_odds = [
	[75, 20, 5],	# Round 1
	[75, 20, 5],	# Round 2
	[75, 20, 5],	# Round 3
	[50, 35, 15],	# Round 4
	[50, 35, 15],	# Round 5
	[50, 35, 15],	# Round 6
	[50, 40, 10],	# Round 7
	[50, 40, 10],	# Round 8
	[40, 40, 20],	# Round 9
	[40, 40, 20],	# Round 10
	[30, 45, 25],	# Round 11
	[30, 45, 25],	# Round 12
	[20, 45, 35],	# Round 13
	[20, 45, 35],	# Round 14
	[20, 45, 35],	# Round 15
]

signal shop_roll_requested

func _ready() -> void:
	_connect_signals()

func create_random_unit() -> Unit:
	var rng = RandomNumberGenerator.new()
	var current_odds = get_current_shop_odds()

	var possible_units = []
	for i in range(current_odds[0]):
		possible_units.append(common_units[rng.randi_range(0, common_units.size() - 1)])
	
	for i in range(current_odds[1]):
		possible_units.append(uncommon_units[rng.randi_range(0, uncommon_units.size() - 1)])
	
	for i in range(current_odds[2]):
		possible_units.append(rare_units[rng.randi_range(0, rare_units.size() - 1)])
	
	var random_unit = possible_units[rng.randi_range(0, 99)].instantiate()
	return random_unit

func roll_shop_units() -> void:
	for shop_hex: Hex in %ShopHexes.get_children():
		
		if shop_hex.unit_on_hex != null:
			if shop_hex.unit_on_hex.is_frozen:
				continue
			else:
				shop_hex.unit_on_hex.remove_self()

		var new_unit = create_random_unit()
		new_unit.try_connect_to_hex(shop_hex)
		%ShopUnits.add_child(new_unit)
		new_unit.play_new_unit_animations()

func get_current_shop_odds() -> Array:
	return shop_odds[GameManager.current_round - 1]

func _connect_signals() -> void:
	%GoldManager.shop_roll_approved.connect(_on_roll_shop_approved)
	%RerollButton.get_node("Area3D").input_event.connect(_on_roll_shop_pressed)

func _on_roll_shop_pressed(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event.is_action_pressed("LeftClick")):
		shop_roll_requested.emit()

func _on_roll_shop_approved() -> void:
	roll_shop_units()
	shop_roll_audio.play()
