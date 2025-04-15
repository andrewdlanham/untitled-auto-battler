extends Node

var player_gold = 10
var reroll_cost = 2

signal shop_roll_approved
signal unit_purchase_approved(unit: Unit)
signal unit_purchase_denied(unit: Unit)

func _ready() -> void:
	%ShopManager.shop_roll_requested.connect(_on_shop_roll_requested)
	%DragDropManager.unit_purchase_requested.connect(_on_unit_purchase_requested)
	update_gold_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_shop_roll_requested():
	print("Approving shop roll attempt...")
	if (player_gold >= reroll_cost):
		subtract_gold(reroll_cost)
		shop_roll_approved.emit()

func _on_unit_purchase_requested(unit: Unit):
	if player_gold >= unit.cost:
		subtract_gold(unit.cost)
		unit_purchase_approved.emit(unit)
	else:
		unit_purchase_denied.emit(unit)

func add_gold(amount):
	player_gold += amount
	update_gold_label()
	
func subtract_gold(amount):
	player_gold -= amount
	update_gold_label()

func update_gold_label():
	%GoldCountLabel.text = str(player_gold)
