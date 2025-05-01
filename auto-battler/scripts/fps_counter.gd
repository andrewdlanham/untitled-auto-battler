extends Node2D

@onready var fps_label: Label = $FPS_Label

func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
