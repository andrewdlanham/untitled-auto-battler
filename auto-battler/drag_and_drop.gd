extends Node3D

const RAY_LENGTH = 100
const UNIT_MASK = 1
const FLOOR_MASK = 2
const UNIT_FLOOR_MASK = 3	# Enables both layers 1 and 2

@onready var camera: Camera3D = %Camera3D

var is_dragging
var dragged_object
var dragged_object_collision_shape
var raycast_collision_mask = UNIT_MASK

func _process(_delta):
	if is_dragging: update_dragged_object_position()

func _input(event):
	if Input.is_action_just_pressed("LeftClick"):
		print("Left click")
		if is_dragging: return
		raycast_collision_mask = UNIT_MASK
		var raycast_collision_info = get_raycast_collision_info()
		print(raycast_collision_info)
		if !raycast_collision_info.is_empty():
			dragged_object = raycast_collision_info["collider"].get_node("../.")
			print("Dragging: " + dragged_object.name)
			dragged_object_collision_shape = dragged_object.find_child("CollisionShape3D")
			dragged_object_collision_shape.set_disabled(true)
			raycast_collision_mask = FLOOR_MASK
			is_dragging = true
			
	elif Input.is_action_just_released("LeftClick"):
		print("Left click released")
		if is_dragging: 
			raycast_collision_mask = UNIT_MASK
			is_dragging = false
			snap_object_to_nearest_space(dragged_object)
			dragged_object_collision_shape.set_disabled(false)
			dragged_object = null
			dragged_object_collision_shape = null

 
func get_raycast_collision_info():
	
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()

	var ray_start_point = camera.project_ray_origin(mouse_position)
	var ray_end_point = ray_start_point + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var ray_query = PhysicsRayQueryParameters3D.create(ray_start_point, ray_end_point)
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = true
	ray_query.collision_mask = raycast_collision_mask
	
	var intersect_ray_result = space_state.intersect_ray(ray_query)
	
	return intersect_ray_result
	
func update_dragged_object_position():
	var raycast_collision_info = get_raycast_collision_info()
	if raycast_collision_info.is_empty(): return
	if raycast_collision_info["position"]:
		var updated_position = raycast_collision_info["position"]
		dragged_object.global_position = Vector3(
			updated_position.x,
			dragged_object.global_position.y,
			updated_position.z
		)

func snap_object_to_nearest_space(object_to_snap):
	var closest_snap_point = null
	var closest_snap_distance = INF
	for snap_point in get_tree().get_nodes_in_group("Snap Points"):
		var snap_point_origin = snap_point.global_transform.origin
		var distance_to_snap_point = object_to_snap.position.distance_to(snap_point_origin)
		if distance_to_snap_point < closest_snap_distance:
			closest_snap_distance = distance_to_snap_point
			closest_snap_point = snap_point
		
	object_to_snap.position = closest_snap_point.global_transform.origin
