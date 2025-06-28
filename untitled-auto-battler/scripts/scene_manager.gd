extends Node

var active_scene: Node
var preparation_scene: Node3D

const REGISTER_SCENE_PATH: String = "res://scenes/register.tscn"
const LOGIN_SCENE_PATH: String = "res://scenes/auth.tscn"
const MENU_SCENE_PATH: String = "res://scenes/menu.tscn"
const COMBAT_SCENE_PATH: String = "res://scenes/combat.tscn"
const PREP_SCENE_PATH: String = "res://scenes/prep_scene.tscn"

func _ready() -> void:
	var cursor = load("res://assets/images/cursors/point.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW)

	active_scene = get_tree().root.get_node("Auth")

func switch_to_scene(scene_path: String) -> void:

	# Check if scene exists
	var scene_resource = load(scene_path)
	if not scene_resource:
		push_error("Failed to load scene: " + scene_path)
		return
	
	# Unload current scene if it exists
	if active_scene and active_scene.get_parent():
		active_scene.queue_free()

	# Switch to new scene
	var new_scene = scene_resource.instantiate()
	get_tree().root.add_child(new_scene)
	active_scene = new_scene
