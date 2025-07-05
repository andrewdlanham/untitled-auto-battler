extends Node3D

@onready var round_label: Label = %RoundLabel

func _ready() -> void:
	_connect_signals()

	GameManager.construct_team(GameManager.player_units, %PlayerHexes.get_children(), %PlayerUnits)
	GameManager.construct_team(GameManager.bench_units, %BenchHexes.get_children(), %BenchUnits)
	GameManager.construct_team(GameManager.shop_units, %ShopHexes.get_children(), %ShopUnits)

	start_new_round()

func start_new_round() -> void:
	GameManager.current_round += 1
	%GoldManager.set_gold(10)
	%ShopManager.roll_shop_units()
	update_unit_count_label()
	update_round_label()

func update_unit_count_label() -> void:
	await get_tree().process_frame		# Allows units time to leave scene before updating the unit count label
	%UnitCountLabel.text = "Units:   " + str(%PlayerUnits.get_children().size()) + " / " + str(GameManager.get_current_unit_cap())

func _on_start_combat_button_pressed(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		GameManager.player_units = get_unit_info(%PlayerUnits)
		GameManager.bench_units = get_unit_info(%BenchUnits)
		GameManager.shop_units = get_unit_info(%ShopUnits)

		if (GameManager.player_units == []):
			SceneManager.switch_to_scene(SceneManager.COMBAT_SCENE_PATH)
			SoundManager.play_music("combat_scene_music")
		else:
			DataManager.store_team_in_db(GameManager.player_units)
			await DataManager.team_stored_in_db
			SceneManager.switch_to_scene(SceneManager.COMBAT_SCENE_PATH)
			SoundManager.play_music("combat_scene_music")

func _connect_signals() -> void:

	# Everything that should trigger update_unit_count_label()
	%DragDropManager.unit_placed.connect(update_unit_count_label)
	%MergeManager.unit_merge_success.connect(update_unit_count_label)
	%GoldManager.unit_sold.connect(update_unit_count_label)
	
	# Connect signals for hex buttons
	%CombatButton.get_node("Area3D").input_event.connect(_on_start_combat_button_pressed)

func update_round_label() -> void:
	round_label.text = "Round   " + str(GameManager.current_round)

func get_unit_info(parent_node: Node) -> Array:
	var unit_info_array = []
	for unit: Unit in parent_node.get_children():
		unit_info_array.append(unit.get_info_dict())
	return unit_info_array
