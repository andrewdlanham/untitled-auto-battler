extends Node

var player_gold = 10
@onready var gold_count_label: Label = %GoldCountLabel

var test_unit = preload("res://Units/test_unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_roll_shop_button_pressed() -> void:
	print("Rolling shop...")
	if (player_gold >= 2) :
		for shop_hex in %ShopHexes.get_children():
			# Remove previous unit
			shop_hex.free_unit_on_hex()
			# Add new random unit
			var new_unit = test_unit.instantiate()
			new_unit.position = shop_hex.snap_point.global_transform.origin
			shop_hex.unit_on_hex = new_unit
			new_unit.current_hex = shop_hex
			%PlayerUnits.add_child(new_unit)
		player_gold -= 2
		gold_count_label.text = str(player_gold)
		

		
