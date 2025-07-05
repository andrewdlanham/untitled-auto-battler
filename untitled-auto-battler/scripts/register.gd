extends Node2D

const FIELD_HIDDEN_ICON = preload("res://assets/images/not_visible.png")
const FIELD_VISIBLE_ICON = preload("res://assets/images/visible.png")

func _on_go_to_login_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.LOGIN_SCENE_PATH)

func _on_register_user_pressed() -> void:
	Auth.register_user(%EmailInput.text, %PasswordInput.text, false)

func _on_show_password_button_pressed() -> void:
	%PasswordInput.secret = !%PasswordInput.secret
	if (%ShowPasswordButton.icon == FIELD_HIDDEN_ICON):
		%ShowPasswordButton.icon = FIELD_VISIBLE_ICON
	else:
		%ShowPasswordButton.icon = FIELD_HIDDEN_ICON
