extends Node2D

@onready var email_input: LineEdit = %EmailInput
@onready var forgot_password_button: Button = %ForgotPasswordButton
@onready var alert_label: Label = %AlertLabel


func _ready() -> void:
	alert_label.visible = false

func _on_forgot_password_button_pressed() -> void:
	var email = email_input.text.strip_edges()
	if email.is_empty() or !is_valid_email(email):
		alert_label.add_theme_color_override("font_color", Color.RED)
		alert_label.text = "Please enter a valid email."
		alert_label.visible = true
		return

	Auth.reset_password_request(email)

func _on_go_to_login_pressed() -> void:
	SceneManager.switch_to_scene(SceneManager.LOGIN_SCENE_PATH)

func is_valid_email(email: String) -> bool:
	var email_regex := RegEx.new()
	email_regex.compile(r"^[\w\.-]+@[\w\.-]+\.\w+$")
	return email_regex.search(email) != null
