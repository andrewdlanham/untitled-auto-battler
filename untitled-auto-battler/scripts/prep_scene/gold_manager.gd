extends Node

var player_gold: int = 0
var reroll_cost: int = 1

signal shop_roll_approved
signal unit_purchase_approved(unit: Unit)
signal unit_purchase_denied(unit: Unit)

func _ready() -> void:
	_connect_signals()
	update_gold_label_text()

func _connect_signals() -> void:
	%ShopManager.shop_roll_requested.connect(_on_shop_roll_requested)
	%DragDropManager.unit_purchase_requested.connect(_on_unit_purchase_requested)

func _on_shop_roll_requested() -> void:
	if (player_gold >= reroll_cost):
		subtract_gold(reroll_cost)
		shop_roll_approved.emit()

func _on_unit_purchase_requested(unit: Unit, hex_placed_on: Hex) -> void:
	if player_gold >= unit.cost:
		subtract_gold(unit.cost)
		unit_purchase_approved.emit(unit, hex_placed_on)
	else:
		unit_purchase_denied.emit(unit)

func update_gold_label_text() -> void:
	%GoldCountLabel.text = str(player_gold) + " G"

func set_gold(amount) -> void:
	player_gold = amount
	update_gold_label_text()

func add_gold(amount) -> void:
	player_gold += amount
	update_gold_label_text()

func subtract_gold(amount) -> void:
	player_gold -= amount
	update_gold_label_text()

func get_current_gold() -> int:
	return player_gold
