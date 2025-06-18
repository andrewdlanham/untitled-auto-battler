extends Node3D

func _ready() -> void:
	_connect_signals()
	GameManager.player_units_node = %PlayerUnits
	GameManager.player_hexes_node = %PlayerHexes
	GameManager.round_label = %RoundLabel
	GameManager.update_round_label()
	update_unit_count_label()
	start_new_round()

func start_new_round() -> void:
	%GoldManager.set_gold(10)
	%ShopManager.roll_shop_units()
	update_unit_count_label()

func update_unit_count_label() -> void:
	await get_tree().process_frame		# Allows units time to leave scene before updating the unit count label
	%UnitCountLabel.text = str(%PlayerUnits.get_children().size()) + " / " + str(GameManager.get_current_unit_cap())

func _on_start_combat_button_pressed() -> void:
	DataManager.store_team_in_db()
	await DataManager.team_stored_in_db
	GameManager.change_to_combat_scene()

func _connect_signals() -> void:

	# Everything that should trigger update_unit_count_label()
	%DragDropManager.unit_placed.connect(update_unit_count_label)
	%MergeManager.unit_merge_success.connect(update_unit_count_label)
	%GoldManager.unit_sold.connect(update_unit_count_label)
