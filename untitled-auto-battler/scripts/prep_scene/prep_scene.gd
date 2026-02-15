extends Node3D

const STARTING_GOLD: int = 10

func _ready() -> void:

	SoundManager.play_music("prep_scene_music")
	_connect_signals()
	GameManager.current_round += 1

	_set_hex_visibilities(GameManager.current_round)

	GameManager.construct_team(GameManager.player_units, %PlayerHexes.get_children(), %PlayerUnits)
	GameManager.construct_team(GameManager.bench_units, %BenchHexes.get_children(), %BenchUnits)
	GameManager.construct_team(GameManager.shop_units, %ShopHexes.get_children(), %ShopUnits)

	%GoldManager.set_gold(STARTING_GOLD)
	%ShopManager.roll_shop_units()
	_update_unit_count_label()
	_update_round_label()

func _connect_signals() -> void:

	# Everything that should trigger _update_unit_count_label()
	%DragDropManager.unit_placed.connect(_update_unit_count_label)
	%MergeManager.unit_merge_success.connect(_update_unit_count_label)
	%UnitStatsPopup.unit_sold.connect(_update_unit_count_label)
	
	# Connect signals for UI buttons
	%EndTurnButton.pressed.connect(_on_end_turn_button_pressed)
	%RerollButton.pressed.connect(%ShopManager.request_shop_roll)

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

func enable_drag_drop() -> void:
	%DragDropManager.enable()

func disable_drag_drop() -> void:
	%DragDropManager.disable()

func _end_turn() -> void:
	GameManager.player_units = _get_unit_info_array(%PlayerUnits)
	GameManager.bench_units = _get_unit_info_array(%BenchUnits)
	GameManager.shop_units = _get_unit_info_array(%ShopUnits)

	if (GameManager.player_units != []):
		DataManager.store_team_in_db(GameManager.player_units)
		await DataManager.team_stored_in_db
	
	SceneManager.switch_to_scene(SceneManager.COMBAT_SCENE_PATH)

func _set_hex_visibilities(round_num: int) -> void:
	if round_num >= 3:
		%ShopHexD.visible = true
		%BenchHexD.visible = true
	if round_num >= 5:
		%ShopHexE.visible = true
		%BenchHexE.visible = true
	if round_num >= 7:
		%ShopHexF.visible = true
		%BenchHexF.visible = true

#region Buttons

func _on_end_turn_button_pressed() -> void:

	if %GoldManager.get_current_gold() > 0:
		disable_drag_drop()
		%ConfirmEndTurnCanvasLayer.visible = true
	else:
		_end_turn()

func _on_confirm_end_turn_button_pressed() -> void:
	_end_turn()

func _on_return_to_prep_scene_button_pressed() -> void:
	enable_drag_drop()
	%ConfirmEndTurnCanvasLayer.visible = false

#endregion
