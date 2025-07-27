extends Node

@onready var player_units: Node = %PlayerUnits
@onready var enemy_units: Node = %EnemyUnits
@onready var continue_button: Button = %ContinueButton
@onready var wins_label: Label = %WinsLabel
@onready var lives_label: Label = %LivesLabel
@onready var run_summary: Control = %RunSummary

var combat_in_progress: bool = false

var num_player_units
var num_enemy_units

signal get_random_team_requested

func _ready() -> void:
	_connect_all_hexes()
	update_wins_label()
	update_lives_label()
	get_random_team_requested.connect(DataManager._on_get_random_team_requested)
	DataManager.combat_team_received.connect(_on_combat_team_received)
	get_random_team_requested.emit()

func _process(_delta: float) -> void:
	if (combat_in_progress):
		if (num_player_units == 0 or num_enemy_units == 0):
			end_combat()
			if (num_enemy_units == 0):
				GameManager.number_of_wins += 1
				update_wins_label()
			else:
				GameManager.number_of_lives -= 1
				update_lives_label()
			# Player reaches win threshold
			if (GameManager.number_of_wins >= GameManager.WIN_THRESHOLD):
				handle_end_of_run(true)
			# Player runs out of lives
			elif (GameManager.number_of_lives <= 0):
				handle_end_of_run(false)
			# Keep playing
			else:
				continue_button.visible = true

func start_combat() -> void:
	combat_in_progress = true
	num_player_units = player_units.get_children().size()
	num_enemy_units = enemy_units.get_children().size()
	var active_units = player_units.get_children() + enemy_units.get_children()
	for unit in active_units:
		unit.enable_combat()
		unit.unit_died.connect(_on_unit_died)

func end_combat() -> void:

	combat_in_progress = false

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
	if (team == "PLAYER"): num_player_units -= 1
	if (team == "ENEMY"): num_enemy_units -= 1

func _on_combat_team_received(enemy_unit_info_array) -> void:
	GameManager.construct_team(enemy_unit_info_array, %EnemyHexes.get_children(), %EnemyUnits)
	GameManager.construct_team(GameManager.player_units, %PlayerHexes.get_children(), %PlayerUnits)
	start_combat()

func _on_menu_button_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.MENU_SCENE_PATH)
	UI.hide_toggle_music_button()
	SoundManager.stop_music()

func _on_continue_button_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.PREP_SCENE_PATH)
	SoundManager.play_music("prep_scene_music")

func update_wins_label() -> void:
	wins_label.text = "WINS: " + str(GameManager.number_of_wins) + " / " + str(GameManager.WIN_THRESHOLD)

func update_lives_label() -> void:
	lives_label.text = "LIVES: " + str(GameManager.number_of_lives) + " / 5" 

func handle_end_of_run(player_won: bool) -> void:
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
