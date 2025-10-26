extends Node

@onready var player_units: Node = %PlayerUnits
@onready var enemy_units: Node = %EnemyUnits
@onready var continue_button: Button = %ContinueButton
@onready var wins_label: Label = %WinsLabel
@onready var lives_label: Label = %LivesLabel
@onready var run_summary: Control = %RunSummary
@onready var enemy_name_label: Label = %EnemyNameLabel

var _combat_in_progress: bool = false
var _num_player_units
var _num_enemy_units

signal get_random_team_requested

func _ready() -> void:
	_connect_all_hexes()
	_update_wins_label()
	_update_lives_label()
	get_random_team_requested.connect(DataManager._on_get_random_team_requested)
	DataManager.combat_team_received.connect(_on_combat_team_received)
	get_random_team_requested.emit()

func _process(_delta: float) -> void:
	if (_combat_in_progress):
		if (_num_player_units == 0 or _num_enemy_units == 0):
			_end_combat()
			if (_num_enemy_units == 0):
				GameManager.number_of_wins += 1
				_update_wins_label()
			else:
				GameManager.number_of_lives -= 1
				_update_lives_label()
			# Player reaches win threshold
			if (GameManager.number_of_wins >= GameManager.WIN_THRESHOLD):
				_handle_end_of_run(true)
			# Player runs out of lives
			elif (GameManager.number_of_lives <= 0):
				_handle_end_of_run(false)
			# Keep playing
			else:
				continue_button.visible = true

func _start_combat() -> void:
	_combat_in_progress = true
	_num_player_units = player_units.get_children().size()
	_num_enemy_units = enemy_units.get_children().size()
	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.enable_combat()
		unit.unit_died.connect(_on_unit_died)

func _end_combat() -> void:

	_combat_in_progress = false

	# Disconnect signals if needed
	if get_random_team_requested.is_connected(DataManager._on_get_random_team_completed):
		get_random_team_requested.disconnect(DataManager._on_get_random_team_requested)
	if DataManager.combat_team_received.is_connected(_on_combat_team_received):
		DataManager.combat_team_received.disconnect(_on_combat_team_received)

	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.disable_combat()
		if unit.unit_died.is_connected(_on_unit_died):
			unit.unit_died.disconnect(_on_unit_died)

func _on_unit_died(_unit: Unit, team: String) -> void:
	if (team == "PLAYER"): _num_player_units -= 1
	if (team == "ENEMY"): _num_enemy_units -= 1

func _on_combat_team_received(enemy_unit_info_array, enemy_user_id) -> void:

	# Construct enemy team if valid team exists
	if enemy_unit_info_array != []:
		GameManager.construct_team(enemy_unit_info_array, %EnemyHexes.get_children(), %EnemyUnits)
	# Construct a mirror match if no valid team exists
	else:
		GameManager.construct_team(GameManager.player_units, %EnemyHexes.get_children(), %EnemyUnits)

	# Set up enemy name label
	DataManager.get_display_name_from_id(enemy_user_id)
	var enemy_display_name: String = await DataManager.display_name_received
	if enemy_display_name == "null": enemy_display_name = "Guest"
	enemy_name_label.text = enemy_display_name.replace('"', "") + "'s Team"

	# Construct player's team
	GameManager.construct_team(GameManager.player_units, %PlayerHexes.get_children(), %PlayerUnits)

	_start_combat()

func _on_menu_button_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.MENU_SCENE_PATH)
	UI.hide_toggle_music_button()
	SoundManager.stop_music()

func _on_continue_button_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.PREP_SCENE_PATH)
	SoundManager.play_music("prep_scene_music")

func _update_wins_label() -> void:
	wins_label.text = "WINS: " + str(GameManager.number_of_wins) + " / " + str(GameManager.WIN_THRESHOLD)

func _update_lives_label() -> void:
	lives_label.text = "LIVES: " + str(GameManager.number_of_lives) + " / 5" 

func _handle_end_of_run(player_won: bool) -> void:
	%RunResultLabel.text = "You Win!" if player_won else "You Lost..."
	var stats_to_add = {
		"wins": 1 if player_won else 0,
		"losses": 1 if !player_won else 0,
		"round_wins": GameManager.number_of_wins,
		"round_losses": GameManager.MAX_LIVES - GameManager.number_of_lives
	}
	DataManager.increment_stats(stats_to_add)
	run_summary.visible = true

func _connect_all_hexes() -> void:
	var all_hexes = %PlayerHexes.get_children() + %EnemyHexes.get_children() + %NeutralHexes.get_children()
	for hex: Hex in all_hexes:
		hex.connect_to_neighbor_hexes(all_hexes)
