extends Node2D

func _on_play_game_button_pressed() -> void:
	print("Starting game...")
	GameManager.start_game()
	self.queue_free()
