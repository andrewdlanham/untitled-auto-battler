# TODO: Upgrade unit stats on level-up

extends Node3D

class_name Unit

@onready var health_label: Label3D = $HealthLabel
@onready var level_label: Label3D = $LevelLabel

@export var unit_name: String
@export var unit_id: String

@export var cost: int = 1
@export var level: int = 1

var team: String
var current_hex: Hex

# Combat variables
var combat_enabled: bool = false
@export var health: float = 100.00
@export var attack_range: int = 3	# TODO: Tie attack range to hexes
@export var target_enemy: Unit

# Signals
signal unit_died(unit: Unit, team: String)

func _ready() -> void:
	update_health_label_text()
	update_level_label_text()

func _process(_delta: float) -> void:
	if(combat_enabled):
		if not is_instance_valid(target_enemy):
			target_closest_enemy()
		if not target_is_in_attack_range():
			var open_hex = get_open_hex_towards_unit(target_enemy)
			move_to_hex(open_hex)
		else:
				# TODO: Implement attacking logic
				pass
	
	combat_enabled = false


#region -- Helpers --
func update_health_label_text() -> void:
	health_label.text = str(health)

func update_level_label_text() -> void:
	level_label.text = "LVL " + str(level)

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
#endregion

func get_open_hex_towards_unit(unit: Unit) -> Hex:
	var closest_hex = null
	var shortest_distance = INF
	for neighborHex in current_hex.neighbors:
		if neighborHex.is_occupied(): 
			continue
		var distance = neighborHex.global_transform.origin.distance_to(unit.global_transform.origin)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_hex = neighborHex
	return closest_hex

func target_is_in_attack_range() -> bool:
	return self.global_transform.origin.distance_to(target_enemy.global_transform.origin) <= self.attack_range

func move_to_hex(hex: Hex) -> void:
	if hex.is_occupied():
		return
	hex.unit_on_hex = self
	current_hex.unit_on_hex = null
	current_hex = hex
	self.position = hex.snap_point.global_transform.origin

func die() -> void:
	unit_died.emit(self, self.team)
	self.queue_free()

func get_closest_enemy() -> Node3D:
	var closest_enemy: Node = null
	var closest_distance: float = INF  # Start with infinite distance
	var enemies
	if team == 'PLAYER': enemies = get_tree().root.get_node("Game/EnemyUnits").get_children()
	elif team == 'ENEMY': enemies = get_tree().root.get_node("Game/PlayerUnits").get_children()
	for enemy in enemies:
		var distance = self.global_transform.origin.distance_to(enemy.global_transform.origin)
		
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
