extends Node3D

func _ready() -> void:
	GameManager.player_units_node = %PlayerUnits
	GameManager.player_hexes_node = %PlayerHexes
	GameManager.round_label = %RoundLabel
	GameManager.update_round_label()

func start_new_round() -> void:
	%GoldManager.set_gold(10)
	%ShopManager.roll_shop_units()
