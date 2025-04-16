extends Node

var possible_units = [
	preload("res://units/test_unit.tscn"),
	preload("res://units/archer.tscn")
]

signal shop_roll_requested

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_signals()
	
func _connect_signals():
	%GoldManager.shop_roll_approved.connect(_on_roll_shop_approved)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_roll_shop_button_pressed() -> void:
	print("Attempting shop roll...")
	shop_roll_requested.emit()
		
func _on_roll_shop_approved():
	print("Rolling shop...")
	for shop_hex in %ShopHexes.get_children():
		# Remove previous unit
		shop_hex.free_unit_on_hex()
		# Add new random unit
		var rng = RandomNumberGenerator.new()
		var random_unit_index = rng.randi_range(0, possible_units.size() - 1)
		var new_unit = possible_units[random_unit_index].instantiate()
		new_unit.position = shop_hex.snap_point.global_transform.origin
		shop_hex.unit_on_hex = new_unit
		new_unit.current_hex = shop_hex
		%ShopUnits.add_child(new_unit)
