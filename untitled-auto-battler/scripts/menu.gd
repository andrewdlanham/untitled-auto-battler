extends Node2D

@onready var logged_in_as_label: Label = $LoggedInAsLabel

func _ready() -> void:
	DataManager.leaderboard_received.connect(update_leaderboard_label)
	logged_in_as_label.text = "Logged in as " + DataManager.user_email
	if (DataManager.user_email.contains("guest")):
		logged_in_as_label.text = "Logged in as Guest"

func _on_play_game_button_pressed() -> void:
	print("Starting game...")
	GameManager.start_game()


func _on_increment_user_wins_button_pressed() -> void:
	print("id: " + str(DataManager.user_id))
	DataManager.increment_user_wins()

func _on_get_leaderboard_pressed() -> void:
	DataManager.get_leaderboard()

func update_leaderboard_label(data: Array):
	var leaderboard_text = ""
	for i in data.size():
		var entry = data[i]
		leaderboard_text += str(i + 1) + ". " + entry["user_id"].substr(0, 8) + " - " + str(entry["wins"]) + " W\n"
	%LeaderboardLabel.text = leaderboard_text
