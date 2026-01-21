extends Node3D

const STARTING_GOLD: int = 10

func _ready() -> void:
	_connect_signals()

	GameManager.construct_team(GameManager.player_units, %PlayerHexes.get_children(), %PlayerUnits)
	GameManager.construct_team(GameManager.bench_units, %BenchHexes.get_children(), %BenchUnits)
	GameManager.construct_team(GameManager.shop_units, %ShopHexes.get_children(), %ShopUnits)

	_start_new_round()

func _connect_signals() -> void:

	# Everything that should trigger _update_unit_count_label()
	%DragDropManager.unit_placed.connect(_update_unit_count_label)
	%MergeManager.unit_merge_success.connect(_update_unit_count_label)
	%UnitStatsPopup.unit_sold.connect(_update_unit_count_label)
	
	# Connect signals for UI buttons
	%CombatButton.pressed.connect(_on_start_combat_button_pressed)
	%RerollButton.pressed.connect(%ShopManager.request_shop_roll)

func _start_new_round() -> void:
	GameManager.current_round += 1
	%GoldManager.set_gold(STARTING_GOLD)
	%ShopManager.roll_shop_units()
	_update_unit_count_label()
	_update_round_label()

func _update_unit_count_label() -> void:
	await get_tree().process_frame		# Allows units time to leave scene before updating the unit count label
	%UnitCountLabel.text = "Units: " + str(%PlayerUnits.get_children().size()) + " / " + str(GameManager.get_current_unit_cap())

func _update_round_label() -> void:
	%RoundLabel.text = "Round   " + str(GameManager.current_round)

func _get_unit_info_array(parent_node: Node) -> Array:
	var unit_info_array = []
	for unit: Unit in parent_node.get_children():
		unit_info_array.append(unit.get_info_dict())
	return unit_info_array

#region Buttons

func _on_start_combat_button_pressed() -> void:

	GameManager.player_units = _get_unit_info_array(%PlayerUnits)
	GameManager.bench_units = _get_unit_info_array(%BenchUnits)
	GameManager.shop_units = _get_unit_info_array(%ShopUnits)

	if (GameManager.player_units == []):
		SceneManager.switch_to_scene(SceneManager.COMBAT_SCENE_PATH)
		SoundManager.play_music("combat_scene_music")
	else:
		DataManager.store_team_in_db(GameManager.player_units)
		await DataManager.team_stored_in_db
		SceneManager.switch_to_scene(SceneManager.COMBAT_SCENE_PATH)
		SoundManager.play_music("combat_scene_music")

func _on_menu_button_pressed() -> void:
	%ConfirmReturnMenuPanel.visible = true
	%DragDropManager.disable()

func _on_confirm_return_menu_button_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.MENU_SCENE_PATH)
	UI.hide_toggle_music_button()
	SoundManager.stop_music()

func _on_return_to_game_button_pressed() -> void:
	%ConfirmReturnMenuPanel.visible = false
	%DragDropManager.enable()

#endregion
