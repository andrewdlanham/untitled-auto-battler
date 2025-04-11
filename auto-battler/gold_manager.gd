extends Node

var player_gold = 10
@onready var gold_count_label: Label = %GoldCountLabel

signal shop_roll_approved

func _ready() -> void:
	%ShopManager.attempt_shop_roll.connect(approve_shop_roll_attempt)
	update_gold_count_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func approve_shop_roll_attempt():
	print("Approving shop roll attempt...")
	if (player_gold >= 2):
		shop_roll_approved.emit()
		player_gold -= 2
		update_gold_count_text()
	pass

func update_gold_count_text():
	gold_count_label.text = str(player_gold)
