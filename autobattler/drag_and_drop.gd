extends Node3D

const RAY_LENGTH = 500

@onready var camera: Camera3D = %Camera3D

var isDraggingObject
var objectToDrag

func _process(delta):
	if isDraggingObject:
		var newPosition = get_raycast_intersect().position
		if newPosition == null : return
		newPosition.y = objectToDrag.global_position.y
		objectToDrag.global_position = newPosition

func _input(event):
	var result = get_raycast_intersect()
	if Input.is_action_just_pressed("LeftClick"):
		print("Left click detected")
		if !result.is_empty():
			print(result.collider)
			objectToDrag = result["collider"].get_node("CollisionShape3D")

			print(objectToDrag)
			isDraggingObject = true
	elif Input.is_action_just_released("LeftClick"):
		print("Left click released")
		isDraggingObject = false
		objectToDrag = null

func get_raycast_intersect():
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	return result
