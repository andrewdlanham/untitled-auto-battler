extends Node3D

func _ready() -> void:
	%StoreTeamButton.pressed.connect(DataManager._on_store_team_in_db_pressed)
	%DragDropManager.new_unit_placed.connect(_on_new_unit_placed)
	%DragDropManager.unit_placed.connect(_on_unit_placed)
	%MergeManager.unit_merge_success.connect(_on_unit_merge_success)
	GameManager.player_units_node = %PlayerUnits
	GameManager.player_hexes_node = %PlayerHexes
	GameManager.round_label = %RoundLabel
	GameManager.update_round_label()
	update_unit_count_label()

func start_new_round() -> void:
	%GoldManager.set_gold(10)
	%ShopManager.roll_shop_units()

func update_unit_count_label() -> void:
	%UnitCountLabel.text = str(%PlayerUnits.get_children().size()) + " / " + str(GameManager.get_current_unit_cap())

func _on_start_combat_button_pressed() -> void:
	GameManager.change_to_combat_scene()

func _on_new_unit_placed(unit: Unit) -> void:
	update_unit_count_label()

func _on_unit_placed() -> void:
	update_unit_count_label()

func _on_unit_merge_success() -> void:
	await get_tree().process_frame	# Ensures that merged units have left the scene
	update_unit_count_label()
