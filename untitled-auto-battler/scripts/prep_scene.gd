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

func _on_start_combat_button_pressed(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var units = GameManager.get_player_unit_info()
		# Make sure units is not empty
		if (units == []):
			print("No team to store...")
			GameManager.change_to_combat_scene()
			return
		else:
			DataManager.store_team_in_db(units)
			await DataManager.team_stored_in_db
			GameManager.change_to_combat_scene()

func _connect_signals() -> void:

	# Everything that should trigger update_unit_count_label()
	%DragDropManager.unit_placed.connect(update_unit_count_label)
	%MergeManager.unit_merge_success.connect(update_unit_count_label)
	%GoldManager.unit_sold.connect(update_unit_count_label)
	
	# Connect signals for hex buttons
	%CombatButton.get_node("Area3D").input_event.connect(_on_start_combat_button_pressed)
