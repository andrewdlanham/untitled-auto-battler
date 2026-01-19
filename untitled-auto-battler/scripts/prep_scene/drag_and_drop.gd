extends Node3D

const RAY_LENGTH: int = 100
const UNIT_MASK: int = 1
const FLOOR_MASK: int = 2
const UNIT_FLOOR_MASK: int = 3	# Enables both layers 1 and 2

var is_dragging: bool
var dragged_object: Node3D
var dragged_object_collision_shape: CollisionShape3D
var raycast_collision_mask: int = UNIT_MASK

signal unit_purchase_requested(unit: Unit, hex_placed_on: Hex)
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
				var dropped_hex: Hex = dragged_object.get_nearest_hex()
				if (dropped_hex == null or dropped_hex.is_shop_hex()):
					dragged_object.snap_to_current_hex()
				# Swapping units
				elif (dropped_hex.is_occupied() and not origin_hex.is_shop_hex() and dropped_hex.unit_on_hex != dragged_object):
					swap_units(dragged_object, dropped_hex.unit_on_hex)
				# Prevent drop if hex is occupied
				elif (dropped_hex.is_occupied()):
					dragged_object.snap_to_current_hex()
				# Buying units with no available space
				elif ((dropped_hex.is_player_hex() or dropped_hex.is_bench_hex()) and origin_hex.is_shop_hex() and GameManager.is_active_units_full() and %MergeManager.unit_would_trigger_merge(dragged_object)):
					unit_purchase_requested.emit(dragged_object, dropped_hex)
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

				SoundManager.play_sfx("unit_placed")

func get_raycast_collision_info() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mouse_position = %MainCamera.get_viewport().get_mouse_position()
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

func swap_units(unit_1: Unit, unit_2: Unit) -> void:
	var hex_1 = unit_1.current_hex
	var hex_2 = unit_2.current_hex
	unit_1.current_hex = null
	unit_2.current_hex = null
	hex_1.unit_on_hex = null
	hex_2.unit_on_hex = null
	unit_1.try_connect_to_hex(hex_2)
	unit_2.try_connect_to_hex(hex_1)
	var temp = unit_1.get_parent()
	unit_1.get_parent().remove_child(unit_1)
	unit_2.get_parent().add_child(unit_1)
	unit_2.get_parent().remove_child(unit_2)
	temp.add_child(unit_2)

func _on_unit_purchase_approved(unit: Unit, hex_placed_on: Hex) -> void:
	unit.unfreeze()
	unit.try_connect_to_hex(hex_placed_on)
	unit.team = "PLAYER"
	
	%ShopUnits.remove_child(unit)
	%UnitStatsPopup.show_stats(unit)

	if hex_placed_on.is_player_hex():
		%PlayerUnits.add_child(unit)
	elif hex_placed_on.is_bench_hex():
		%BenchUnits.add_child(unit)

	unit_placed.emit()
	unit.animation_player.stop()
	unit.body.rotation = Vector3.ZERO

func _on_unit_purchase_denied(unit: Unit) -> void:
	printerr("Unit purchase denied")
	unit.snap_to_current_hex()

func enable() -> void:
	set_process(true)
	set_process_input(true)

func disable() -> void:
	set_process(false)
	set_process_input(false)
