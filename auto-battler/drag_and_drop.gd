extends Node3D

const RAY_LENGTH = 1000

@onready var camera: Camera3D = %Camera3D

var is_dragging
var dragged_object

func _process(delta):
	if is_dragging: update_dragged_object_position()

func _input(event):
	if Input.is_action_just_pressed("LeftClick"):
		print("Left click detected")
		var ray_intersect_dict = get_raycast_intersect()
		if !ray_intersect_dict.is_empty():
			dragged_object = ray_intersect_dict["collider"].get_node("CollisionShape3D")
			is_dragging = true
	elif Input.is_action_just_released("LeftClick"):
		print("Left click released")
		dragged_object = null
		is_dragging = false

 
func get_raycast_intersect():
	# TODO : Rename / refactor this function
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_position)
	var end = origin + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	return space_state.intersect_ray(query)
	
func update_dragged_object_position():
	var updated_position = get_raycast_intersect().position
	if updated_position:
		dragged_object.global_position = Vector3(
			updated_position.x,
			dragged_object.global_position.y,
			updated_position.z
		)
