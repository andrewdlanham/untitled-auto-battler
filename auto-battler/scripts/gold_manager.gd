extends Node

var player_gold = 10
var reroll_cost = 2

#region -- Signals --
signal shop_roll_approved
signal unit_purchase_approved(unit: Unit)
signal unit_purchase_denied(unit: Unit)
#endregion

func _ready() -> void:
	connect_signals()
	update_gold_label_text()

func connect_signals() -> void:
	%ShopManager.shop_roll_requested.connect(_on_shop_roll_requested)
	%DragDropManager.unit_purchase_requested.connect(_on_unit_purchase_requested)

#region -- Signal Handlers --
func _on_shop_roll_requested():
	if (player_gold >= reroll_cost):
		subtract_gold(reroll_cost)
		shop_roll_approved.emit()

func _on_unit_purchase_requested(unit: Unit):
	if player_gold >= unit.cost:
		subtract_gold(unit.cost)
		unit_purchase_approved.emit(unit)
	else:
		unit_purchase_denied.emit(unit)
#endregion

#region -- Helpers --
func update_gold_label_text():
	%GoldCountLabel.text = str(player_gold) + " G"

func add_gold(amount):
	player_gold += amount
	update_gold_label_text()
	
func subtract_gold(amount):
	player_gold -= amount
	update_gold_label_text()
#endregion
