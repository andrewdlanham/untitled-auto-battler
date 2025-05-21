extends Node3D	# Script must be on Node3D to access get_world_3d()

const RAY_LENGTH = 100
const UNIT_MASK = 1
const FLOOR_MASK = 2
const UNIT_FLOOR_MASK = 3	# Enables both layers 1 and 2

var is_dragging
var dragged_object
var dragged_object_collision_shape
var raycast_collision_mask = UNIT_MASK

signal unit_purchase_requested(unit: Unit, hex_placed_on: Hex)
signal unit_sell_requested(unit: Unit)

signal unit_placed()

func _ready() -> void:
	%GoldManager.unit_purchase_approved.connect(_on_unit_purchase_approved)
	%GoldManager.unit_purchase_denied.connect(_on_unit_purchase_denied)

func _process(_delta) -> void:
	if is_dragging: update_dragged_object_position()

func _input(_event) -> void:
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
			%UnitStatsPopup.show_stats(dragged_object)
	
	elif Input.is_action_just_released("LeftClick"):
		if is_dragging: 
			raycast_collision_mask = UNIT_MASK
			is_dragging = false
			var origin_hex = dragged_object.current_hex
			if dragged_object is Unit:
				var dropped_hex = dragged_object.get_nearest_hex()
				if (dropped_hex == null or dropped_hex.is_shop_hex() or dropped_hex.is_occupied()):
					dragged_object.snap_to_current_hex()
				# Selling units
				elif (dropped_hex.is_sell_hex() and not origin_hex.is_shop_hex()):
					unit_sell_requested.emit(dragged_object)
				# Buying units on player hexes
				elif (dropped_hex.is_player_hex() and origin_hex.is_shop_hex() and not GameManager.is_active_units_full()):
					unit_purchase_requested.emit(dragged_object, dropped_hex)
				# Buying units on bench hexes
				elif (dropped_hex.is_bench_hex() and origin_hex.is_shop_hex()):
					unit_purchase_requested.emit(dragged_object, dropped_hex)
				# Dragging player units to bench
				elif origin_hex.is_player_hex() and dropped_hex.is_bench_hex():
					if (dragged_object.try_connect_to_nearest_hex()):
						%PlayerUnits.remove_child(dragged_object)
						%BenchUnits.add_child(dragged_object)
						unit_placed.emit()
				# Dragging bench units onto player hexes
				elif origin_hex.is_bench_hex() and dropped_hex.is_player_hex() and not GameManager.is_active_units_full():
					if (dragged_object.try_connect_to_nearest_hex()):
						%BenchUnits.remove_child(dragged_object)
						%PlayerUnits.add_child(dragged_object)
						unit_placed.emit()
				# Other dragging
				elif dropped_hex.hex_type == origin_hex.hex_type:
					dragged_object.try_connect_to_nearest_hex()
				else:
					dragged_object.snap_to_current_hex()

				dragged_object_collision_shape.set_disabled(false)
				dragged_object = null
				dragged_object_collision_shape = null

func _on_unit_purchase_approved(unit: Unit, hex_placed_on: Hex) -> void:
	unit.try_connect_to_hex(hex_placed_on)
	unit.unfreeze()
	unit.team = "PLAYER"
	%ShopUnits.remove_child(unit)
	
	if hex_placed_on.is_player_hex():
		%PlayerUnits.add_child(unit)
	elif hex_placed_on.is_bench_hex():
		%BenchUnits.add_child(unit)
	
	unit_placed.emit()

func _on_unit_purchase_denied(unit: Unit) -> void:
	printerr("Unit purchase denied")
	unit.snap_to_current_hex()

func get_raycast_collision_info() -> Dictionary:
	
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

func update_dragged_object_position() -> void:
	var raycast_collision_info = get_raycast_collision_info()
	if raycast_collision_info.is_empty(): return
	if raycast_collision_info["position"]:
		var updated_position = raycast_collision_info["position"]
		dragged_object.global_position = Vector3(
			updated_position.x,
			dragged_object.global_position.y,
			updated_position.z
		)
