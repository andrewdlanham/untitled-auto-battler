extends Node

@onready var toggle_music_button: Button = %ToggleMusicButton
@onready var fps_label: Label = %FPS_Label
@onready var wins_label: Label = %WinsLabel
@onready var lives_label: Label = %LivesLabel

const MUSIC_ON = preload("res://assets/images/music_on.png")
const MUSIC_OFF = preload("res://assets/images/music_off.png")

func _ready() -> void:
	hide_game_ui()

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_toggle_music_button_pressed() -> void:
	SoundManager.toggle_music()
	if toggle_music_button.icon == MUSIC_ON:
		toggle_music_button.icon = MUSIC_OFF
	else:
		toggle_music_button.icon = MUSIC_ON

func hide_game_ui() -> void:
	$CanvasLayer.hide()

func show_game_ui() -> void:
	$CanvasLayer.show()

func _on_menu_button_pressed() -> void:
	%ConfirmReturnMenuPanel.visible = true
	if (SceneManager.active_scene_path == SceneManager.PREP_SCENE_PATH):
		SceneManager.active_scene.disable_drag_drop()

func _on_confirm_return_menu_button_pressed() -> void:
	%ConfirmReturnMenuPanel.visible = false
	SceneManager.switch_to_scene(SceneManager.MENU_SCENE_PATH)
	SoundManager.stop_music()

func _on_return_to_game_button_pressed() -> void:
	%ConfirmReturnMenuPanel.visible = false
	if (SceneManager.active_scene_path == SceneManager.PREP_SCENE_PATH):
		SceneManager.active_scene.enable_drag_drop()

func update_wins_label() -> void:
	wins_label.text = str(GameManager.number_of_wins) + " / " + str(GameManager.WIN_THRESHOLD)

func update_lives_label() -> void:
	lives_label.text = str(GameManager.number_of_lives)
