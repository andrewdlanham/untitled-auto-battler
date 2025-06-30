extends Node

var player_gold: int = 0
var reroll_cost: int = 1

#region -- Signals --
signal shop_roll_approved
signal unit_purchase_approved(unit: Unit)
signal unit_purchase_denied(unit: Unit)
signal unit_sold
#endregion

func _ready() -> void:
	_connect_signals()
	update_gold_label_text()

func _connect_signals() -> void:
	%ShopManager.shop_roll_requested.connect(_on_shop_roll_requested)
	%DragDropManager.unit_purchase_requested.connect(_on_unit_purchase_requested)
	%DragDropManager.unit_sell_requested.connect(_on_unit_sell_requested)

#region -- Signal Handlers --
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

func _on_unit_sell_requested(unit: Unit) -> void:
	# Refund gold based on the unit's level
	match unit.level:
		1: add_gold(1)
		2: add_gold(3)
		3: add_gold(5)
	unit.queue_free()
	unit_sold.emit()
#endregion

func update_gold_label_text() -> void:
	%GoldCountLabel.text = "Gold: " + str(player_gold)

func set_gold(amount) -> void:
	player_gold = amount
	update_gold_label_text()

func add_gold(amount) -> void:
	player_gold += amount
	update_gold_label_text()
	
func subtract_gold(amount) -> void:
	player_gold -= amount
	update_gold_label_text()
