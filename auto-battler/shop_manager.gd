extends Node

@onready var shop_hexes: Node = $"../ShopHexes"

var test_unit = preload("res://Units/test-unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_roll_shop_button_pressed() -> void:
	print("Rolling shop...")
	for shop_hex in shop_hexes.get_children():
		# Remove previous unit
		shop_hex.free_unit_on_hex()
		# Add new random unit
		var new_unit = test_unit.instantiate()
		new_unit.position = shop_hex.snap_point.global_transform.origin
		shop_hex.unit_on_hex = new_unit
		new_unit.current_hex = shop_hex
		get_tree().get_root().add_child(new_unit)
		
		
