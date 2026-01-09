extends Node

var DEFAULT_CURSOR = load("res://assets/images/cursors/point.png")
var CLOSED_HAND_CURSOR = load("res://assets/images/cursors/closed_hand.png")
var CURSOR_HOTSPOT = Vector2(12, 12)

func _ready() -> void:
	Input.set_custom_mouse_cursor(DEFAULT_CURSOR, Input.CURSOR_ARROW, CURSOR_HOTSPOT)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		Input.set_custom_mouse_cursor(CLOSED_HAND_CURSOR, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
	elif Input.is_action_just_released("LeftClick"):
		Input.set_custom_mouse_cursor(DEFAULT_CURSOR, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
