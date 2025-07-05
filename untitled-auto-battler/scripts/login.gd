extends Node2D

const FIELD_HIDDEN_ICON = preload("res://assets/images/not_visible.png")
const FIELD_VISIBLE_ICON = preload("res://assets/images/visible.png")

func _on_play_as_guest_button_pressed() -> void:
	Auth.play_as_guest()

func _on_test_login_pressed() -> void:
	DataManager.first_login = false
	Auth.login_user(DBFunc.TEST_EMAIL, DBFunc.TEST_PASSWORD)

func _on_login_button_pressed() -> void:
	DataManager.first_login = false
	Auth.login_user(%EmailInput.text, %PasswordInput.text)

func _on_go_to_register_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.REGISTER_SCENE_PATH)

func _on_show_password_button_pressed() -> void:
	%PasswordInput.secret = !%PasswordInput.secret
	if (%ShowPasswordButton.icon == FIELD_HIDDEN_ICON):
		%ShowPasswordButton.icon = FIELD_VISIBLE_ICON
	else:
		%ShowPasswordButton.icon = FIELD_HIDDEN_ICON
