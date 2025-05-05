extends Node3D

var shop_manager

signal reroll_requested

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		print("Hex button clicked!")
		reroll_requested.emit()
