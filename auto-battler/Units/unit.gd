extends Node3D
class_name Unit

@onready var health_label: Label3D = $HealthLabel
var current_hex : Hex

@export var unit_name : String
@export var cost : int = 1
@export var rarity : int = 1

# Combat stats
@export var health : float = 100.00
@export var armor : float = 10.00
@export var magic_resistance : float = 10.00
@export var attack_damage : float = 10.00
@export var magic_damage : float = 10.00
@export var attack_range : int = 1
@export var attack_speed : float = 1.00

# Signals
# TODO: Implement hex_change_attempted signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_label.text = str(health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func snap_to_nearest_hex():
	
	# Get closest snap point
	var closest_snap_point = null
	var closest_snap_distance = INF
	for snap_point in get_tree().get_nodes_in_group("Snap Points"):
		var snap_point_origin = snap_point.global_transform.origin
		var distance_to_snap_point = self.position.distance_to(snap_point_origin)
		if distance_to_snap_point < closest_snap_distance:
			closest_snap_distance = distance_to_snap_point
			closest_snap_point = snap_point
		
	# Prevent drag onto shop hex
	if closest_snap_point.get_parent().hex_type == 'SHOP':	# Parent of snap point should always be a hex
		# Snap back to current hex
		self.position = current_hex.snap_point.global_transform.origin
		return
	
	# Snap to closest snap point
	self.position = closest_snap_point.global_transform.origin
	
	# Set reference to unit on hex
	self.current_hex.unit_on_hex = null
	closest_snap_point.get_parent().unit_on_hex = self
	self.current_hex = closest_snap_point.get_parent()
