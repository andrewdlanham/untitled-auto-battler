extends Node3D	# Script must be on Node3D to access get_world_3d()

const RAY_LENGTH = 100
const UNIT_MASK = 1
const FLOOR_MASK = 2
const UNIT_FLOOR_MASK = 3	# Enables both layers 1 and 2

var is_dragging
var dragged_object
var dragged_object_collision_shape
var raycast_collision_mask = UNIT_MASK

signal unit_purchase_requested(unit: Unit)
signal unit_sell_requested(unit: Unit)
signal new_unit_placed(unit: Unit)

func _ready() -> void:
	%GoldManager.unit_purchase_approved.connect(_on_unit_purchase_approved)
	%GoldManager.unit_purchase_denied.connect(_on_unit_purchase_denied)

func _process(_delta):
	if is_dragging: update_dragged_object_position()

func _input(_event):
	if Input.is_action_just_pressed("LeftClick"):
		if is_dragging: return
		raycast_collision_mask = UNIT_MASK
		var raycast_collision_info = get_raycast_collision_info()
		if not raycast_collision_info.is_empty():
			dragged_object = raycast_collision_info["collider"].get_node("../.")
			dragged_object_collision_shape = dragged_object.find_child("CollisionShape3D")
			dragged_object_collision_shape.set_disabled(true)
			raycast_collision_mask = FLOOR_MASK
			is_dragging = true
	
	elif Input.is_action_just_released("LeftClick"):
		if is_dragging: 
			raycast_collision_mask = UNIT_MASK
			is_dragging = false
			if dragged_object is Unit:
				var dropped_hex = dragged_object.get_nearest_hex()
				if (dropped_hex.is_sell_hex() and dragged_object.current_hex.is_player_hex()):
					unit_sell_requested.emit(dragged_object)
				elif (dropped_hex == null or not dropped_hex.is_player_hex()):
					dragged_object.snap_to_current_hex()
				elif dropped_hex.is_player_hex() and dragged_object.current_hex.is_shop_hex():
					unit_purchase_requested.emit(dragged_object)
				elif dropped_hex.is_player_hex():
					dragged_object.try_connect_to_nearest_hex()

				dragged_object_collision_shape.set_disabled(false)
				dragged_object = null
				dragged_object_collision_shape = null

func _on_unit_purchase_approved(unit: Unit):
	unit.try_connect_to_nearest_hex()
	%ShopUnits.remove_child(unit)
	%PlayerUnits.add_child(unit)
	unit.team = "PLAYER"
	new_unit_placed.emit(unit)

func _on_unit_purchase_denied(unit: Unit):
	unit.snap_to_current_hex()

func get_raycast_collision_info():
	
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()

	var ray_start_point = %MainCamera.project_ray_origin(mouse_position)
	var ray_end_point = ray_start_point + %MainCamera.project_ray_normal(mouse_position) * RAY_LENGTH
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
