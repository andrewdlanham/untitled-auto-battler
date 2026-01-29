extends Node2D

func _ready() -> void:
	DataManager.leaderboard_received.connect(_update_leaderboard_label)
	DataManager.get_leaderboard()
	%LoggedInAsLabel.text = "Logged in as " + Auth.user_profile["display_name"]

func _update_leaderboard_label(data: Array) -> void:
	var current_user_id = Auth.get_current_user_id()
	var leaderboard_text := "[center]LEADERBOARD (TOP 10)[/center]\n---------------------------\n"

	for i in data.size():
		var entry = data[i]
		var display_name = entry["display_name"].substr(0, 16)
		var wins = int(entry["wins"])
		var line = "#" + str(i + 1) + " " + display_name + " - " + str(wins) + " W"

		if entry["user_id"] == current_user_id:
			line = "[color=#FFD700]" + line + "[/color]" # Highlight current user

		leaderboard_text += line + "\n"

	%LeaderboardLabel.text = leaderboard_text

#region Buttons

func _on_play_game_button_pressed() -> void:
	GameManager.start_game()

func _on_log_out_button_pressed() -> void:
	DataManager.log_out_current_user()

#endregion
