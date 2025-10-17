extends Node2D

@onready var email_input: LineEdit = %EmailInput
@onready var forgot_password_button: Button = %ForgotPasswordButton

func _on_forgot_password_button_pressed() -> void:
	var email = email_input.text.strip_edges()
	if email.is_empty():
		return

	Auth.reset_password_request(email)
