extends Node2D

@onready var logged_in_as_label: Label = $LoggedInAsLabel
@onready var patch_notes_label: Label = %PatchNotesLabel

func _ready() -> void:
	DataManager.leaderboard_received.connect(update_leaderboard_label)
	DataManager.get_leaderboard()
	logged_in_as_label.text = "Logged in as " + Auth.user_profile["display_name"]

func _on_play_game_button_pressed() -> void:
	GameManager.start_game()

func update_leaderboard_label(data: Array):
	var leaderboard_text = "LEADERBOARD\n\n"
	for i in data.size():
		var entry = data[i]
		leaderboard_text += str(i + 1) + ". " + entry["display_name"].substr(0, 16) + " - " + str(int(entry["wins"])) + " W\n"
	%LeaderboardLabel.text = leaderboard_text

func _on_log_out_button_pressed() -> void:
	DataManager.log_out_current_user()

func _on_patch_notes_button_pressed() -> void:
	patch_notes_label.visible = !patch_notes_label.visible
