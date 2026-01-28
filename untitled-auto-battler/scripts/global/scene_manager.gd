extends Node

var active_scene: Node
var active_scene_path: String

const REGISTER_SCENE_PATH: String = "res://scenes/screens/register.tscn"
const LOGIN_SCENE_PATH: String = "res://scenes/screens/login.tscn"
const MENU_SCENE_PATH: String = "res://scenes/screens/menu.tscn"
const COMBAT_SCENE_PATH: String = "res://scenes/screens/combat.tscn"
const PREP_SCENE_PATH: String = "res://scenes/screens/prep_scene.tscn"
const FORGOT_PASSWORD_SCENE_PATH = "res://scenes/screens/forgot_password.tscn"

func _ready() -> void:
	active_scene = get_tree().root.get_node("Login")

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
	active_scene_path = scene_path
