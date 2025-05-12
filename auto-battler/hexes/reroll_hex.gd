extends Node3D

signal reroll_requested

func _on_area_3d_input_event(_camera: Node, _event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		reroll_requested.emit()
