# TODO: Upgrade unit stats on level-up

extends Node3D

class_name Unit

@onready var health_label: Label3D = $HealthLabel
@onready var level_label: Label3D = $LevelLabel
@onready var name_label: Label3D = $NameLabel

@export var unit_name: String
@export var unit_id: String

@export var cost: int
@export var level: int = 1
@export var rarity: int = 1

var team: String
var current_hex: Hex

# Combat variables
@export var combat_enabled: bool = false
@export var health: float
@export var attack_range: int
@export var attack_speed: float = 0.1

@export var attack_damage: float

@export var target_enemy: Unit

var attack_cooldown: float
var move_cooldown: float = 1
var move_timer: float

var is_moving: bool = false

# Signals
signal unit_died(unit: Unit, team: String)

func _ready() -> void:
	update_health_label_text()
	update_level_label_text()
	update_name_label_text()
	attack_cooldown = 1 / attack_speed
	move_timer = 0.00

func _process(delta: float) -> void:
	
	if health <= 0: die()
	
	attack_cooldown -= delta
	move_timer -= delta
	if move_timer <= 0:
		is_moving = false
	
	if(combat_enabled):
		if not is_instance_valid(target_enemy):
			target_closest_enemy()
		elif not target_is_in_attack_range():
			var open_hex = get_open_hex_towards_unit(target_enemy)
			try_move_to_hex(open_hex)
		elif attack_cooldown <= 0.00:
				attack_target_enemy()
				attack_cooldown = 1 / attack_speed

func update_health_label_text() -> void:
	health_label.text = str(health)

func update_level_label_text() -> void:
	level_label.text = "LVL " + str(level)

func update_name_label_text() -> void:
	name_label.text = self.unit_name

func add_health(amount) -> void:
	health += amount
	update_health_label_text()

func subtract_health(amount) -> void:
	health -= amount
	update_health_label_text()

func level_up() -> void:
	level += 1
	update_level_label_text()

func get_info_dict() -> Dictionary:
	return {
		"unit_name" : self.unit_name,
		"unit_id" : self.unit_id,
		"hex_id" : self.current_hex.hex_id,
		"level" : self.level,
		"cost" : self.cost
		}

func target_is_in_attack_range() -> bool:
	return self.global_position.distance_to(target_enemy.global_position) <= self.attack_range

func die() -> void:
	unit_died.emit(self, self.team)
	remove_self()

func remove_self() -> void:
	current_hex.unit_on_hex = null
	self.queue_free()

func get_closest_enemy() -> Node3D:
	var closest_enemy: Node = null
	var closest_distance: float = INF  # Start with infinite distance
	var enemies
	if team == 'PLAYER': enemies = get_tree().root.get_node("Game/EnemyUnits").get_children()
	elif team == 'ENEMY': enemies = get_tree().root.get_node("Game/PlayerUnits").get_children()
	for enemy in enemies:
		var distance = self.global_position.distance_to(enemy.global_position)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func target_closest_enemy() -> void:
	target_enemy = get_closest_enemy()
	
func enable_combat() -> void:
	combat_enabled = true
	health_label.visible = true

func disable_combat() -> void:
	combat_enabled = false
	health_label.visible = false

func attack_target_enemy() -> void:
	target_enemy.subtract_health(attack_damage)

#region Hex-Related Functions
func snap_to_current_hex() -> void:

	self.position = current_hex.snap_point.global_position

func try_connect_to_hex(hex: Hex, snap_to_hex: bool = true) -> bool:
	
	if (hex.is_occupied()): return false	# Connection failed
	
	if (current_hex): current_hex.unit_on_hex = null	# Disconnect from old hex
	
	current_hex = hex
	current_hex.unit_on_hex = self
	
	if (snap_to_hex): snap_to_current_hex()
	
	return true		# Connection successful

func try_connect_to_nearest_hex() -> bool:

	return try_connect_to_hex(get_nearest_hex())

func get_nearest_hex() -> Hex:

	var closest_snap_point = null
	var closest_snap_distance = INF
	for snap_point in get_tree().get_nodes_in_group("Snap Points"):
		var snap_point_position = snap_point.global_position
		var distance_to_snap_point = self.position.distance_to(snap_point_position)
		if distance_to_snap_point < closest_snap_distance:
			closest_snap_distance = distance_to_snap_point
			closest_snap_point = snap_point
	
	if closest_snap_distance > 1:	# 1 is a temporary value for MAX_SNAP_DISTANCE
		return null
	
	return closest_snap_point.get_parent()

func try_move_to_hex(hex: Hex) -> void:
	
	if is_moving or hex == null or hex.is_occupied(): return

	try_connect_to_hex(hex, false)
	
	is_moving = true
	move_timer = move_cooldown

	var tween := create_tween()
	tween.tween_property(self, "position", hex.snap_point.global_position, move_cooldown)

func get_open_hex_towards_unit(unit: Unit) -> Hex:
	var closest_hex = null
	var shortest_distance = INF
	for neighborHex in current_hex.neighbors:
		if neighborHex.is_occupied(): continue	# Skip occupied hexes
		var distance = neighborHex.global_position.distance_to(unit.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_hex = neighborHex
	return closest_hex
#endregion
