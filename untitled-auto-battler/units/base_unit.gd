extends Node3D

class_name Unit

@onready var level_label: Label3D = $Labels/LevelLabel
@onready var health_progress_bar: ProgressBar = $HealthBar/SubViewport/HealthProgressBar
@onready var health_bar_sprite: Sprite3D = $HealthBar/HealthBarSprite
@onready var health_bar_anchor_point: Node3D = $Body/HealthBarAnchorPoint
@onready var frozen_mesh: MeshInstance3D = $FrozenMesh
@onready var body: Area3D = $Body
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_audio: AudioStreamPlayer3D = $AttackAudio

@export var unit_name: String
@export var unit_id: String

@export var cost: int
@export var rarity: String
@export var level: int = 1

@export var team: String
@export var current_hex: Hex
@export var current_hex_id: String

@export var max_health: float
@export var health: float
@export var attack_speed: float
@export var attack_damage: float
@export var attack_range: int

@export var move_cooldown: float = 1.50
@export var move_timer: float

@export var is_moving: bool = false
@export var is_attacking: bool = false
@export var is_frozen: bool = false

@export var target_enemy: Unit = null
@export var combat_enabled: bool = false

signal unit_died(unit: Unit, team: String)

func _ready() -> void:
	set_unit_stats()

func _process(delta: float) -> void:

	if(combat_enabled):

		if health <= 0: die()

		face_target()

		move_timer -= delta

		if move_timer <= 0:
			is_moving = false

		if is_moving: return

		if target_enemy == null or target_enemy.visible == false or get_closest_enemy() != target_enemy:
			target_closest_enemy()	# Switch target
		elif not target_is_in_attack_range():
			var open_hex = get_open_hex_towards_unit(target_enemy)
			if open_hex != null:
				try_move_to_hex(open_hex)
			else:
				target_closest_enemy()
		elif not is_attacking:
				attack_target_enemy()

func set_unit_stats() -> void:
	max_health = UnitRegistry.get_stat(unit_id, level, "hp")
	health = max_health
	health_progress_bar.max_value = health
	attack_damage = UnitRegistry.get_stat(unit_id, level, "att_dmg")
	attack_speed = UnitRegistry.get_stat(unit_id, level, "att_spd")
	
	cost = UnitRegistry.get_stat(unit_id, level, "cost")
	rarity = UnitRegistry.get_stat(unit_id, level, "rarity")
	
	var new_scale: float = UnitRegistry.get_stat(unit_id, level, "scale")
	body.scale = Vector3(new_scale, new_scale, new_scale)
	health_bar_sprite.global_position = health_bar_anchor_point.global_position
	
	_update_level_label_text()
	_update_health_bar()

func freeze() -> bool:

	if (is_frozen or self.team == "PLAYER"): 
		return false	# Freeze unsuccessful
	else:
		is_frozen = true
		frozen_mesh.visible = true
		animation_player.stop()
		return true		# Freeze successful

func unfreeze() -> void:
	is_frozen = false
	frozen_mesh.visible = false
	if self.team != "PLAYER":
		animation_player.play("bob")

func die() -> void:
	disable_combat()
	current_hex.unit_on_hex = null
	self.visible = false
	unit_died.emit(self, self.team)

func remove_self() -> void:
	current_hex.unit_on_hex = null
	self.queue_free()

func _update_health_bar() -> void:
	health_progress_bar.value = health

func _update_level_label_text() -> void:
	level_label.text = str(level)

func add_health(amount) -> void:
	health += amount
	_update_health_bar()

func subtract_health(amount) -> void:
	health -= amount
	_update_health_bar()

func level_up() -> void:
	level += 1
	set_unit_stats()

func get_info_dict() -> Dictionary:
	return {
		"unit_name" : self.unit_name,
		"unit_id" : self.unit_id,
		"hex_id" : self.current_hex.hex_id,
		"level" : self.level,
		"frozen": self.is_frozen,
	}

func target_is_in_attack_range() -> bool:
	return self.global_position.distance_to(target_enemy.global_position) <= self.attack_range

func get_closest_enemy() -> Node3D:
	# Assumes active_scene is combat scene
	var closest_enemy: Node = null
	var closest_distance: float = INF
	var enemies
	if team == 'PLAYER': 
		enemies = SceneManager.active_scene.get_node("EnemyUnits").get_children()
	elif team == 'ENEMY': 
		enemies = SceneManager.active_scene.get_node("PlayerUnits").get_children()
	for enemy in enemies:
		if enemy.visible == false: continue
		var distance = self.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func target_closest_enemy() -> void:
	target_enemy = get_closest_enemy()
	face_target()

func enable_combat() -> void:
	combat_enabled = true
	health = max_health
	health_progress_bar.max_value = health
	health_progress_bar.visible = true

func disable_combat() -> void:
	combat_enabled = false
	is_attacking = false
	health_progress_bar.visible = false
	is_moving = false
	target_enemy = null

func attack_target_enemy() -> void:

	is_attacking = true

	var attack_length = 1.00 / attack_speed

	animation_player.speed_scale = attack_speed
	animation_player.play("attack")
	animation_player.animation_finished.connect(_on_attack_animation_complete)
	
	await get_tree().create_timer(attack_length / 2.00).timeout

	if is_instance_valid(target_enemy):
		attack_audio.pitch_scale = randf_range(0.5, 1.5)
		attack_audio.volume_db = randf_range(-3.0, -1.0)
		attack_audio.play()
		target_enemy.subtract_health(attack_damage)

func _on_attack_animation_complete(_animation_name: String) -> void:
	animation_player.animation_finished.disconnect(_on_attack_animation_complete)
	is_attacking = false

func snap_to_current_hex() -> void:
	self.position = current_hex.snap_point.global_position

func try_connect_to_hex(hex: Hex, snap_to_hex: bool = true) -> bool:
	
	if (hex.is_occupied()): return false	# Connection failed
	
	if (current_hex): current_hex.unit_on_hex = null	# Disconnect from old hex
	
	current_hex = hex
	current_hex_id = current_hex.hex_id
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
	if (shortest_distance < self.global_position.distance_to(unit.global_position)):
		return closest_hex
	else:
		return null

func play_new_unit_animations() -> void:
	animation_player.play("spin")
	await animation_player.animation_finished
	animation_player.play("bob")

func face_target():
	if target_enemy and target_enemy.is_inside_tree():
		look_at(target_enemy.global_transform.origin, Vector3.UP)
		rotate_y(deg_to_rad(180))	# Flip because look_at assumes -Z is forwards
