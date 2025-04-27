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
@export var attack_range: int = 1
@export var target_enemy: Unit

# Signals
signal unit_died(unit: Unit, team: String)

func _ready() -> void:
	update_health_label_text()
	update_level_label_text()

func _process(delta: float) -> void:
	if(combat_enabled):
		target_enemy = get_tree().root.get_node("Game/EnemyUnits").get_children()[0]	# Temporary target logic
		if target_enemy == null:
			# TODO: Target closest enemy
			pass
		if !target_is_in_attack_range():
			var hex_to_move_to = get_free_hex_closest_to_unit(target_enemy)
			# TODO: Implement moving to new hex
		else:
				# TODO: Implement attacking logic
				pass
		
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

func get_free_hex_closest_to_unit(unit: Unit) -> Hex:
	var closest_hex = null
	var shortest_distance = INF
	for neighborHex in current_hex.neighbors:
		if neighborHex.is_occupied(): continue
		var distance = neighborHex.global_transform.origin.distance_to(unit.global_transform.origin)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_hex = neighborHex
	return closest_hex

func target_is_in_attack_range() -> bool:
	# TODO: Implement this function
	return false

func move_to_hex(hex: Hex) -> void:
	# TODO: Implement this function
	pass

func die() -> void:
	unit_died.emit(self, self.team)
	self.queue_free()
