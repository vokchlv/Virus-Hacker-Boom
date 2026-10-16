"""
Erstellung und Steuerung eines Gegners. Dieser kann entweder Nah- oder Fernkampf sein.
CharacterBody2D
	Layer 3: Gegner
	Mask 1: Wand (Abprall an Wänden)

DetectionArea
	Layer: /
	Mask: 2 (Player)
"""
class_name Enemy
extends CharacterBody2D

enum CombatType { MELEE, RANGED }

signal player_detected(player: CharacterBody2D)
signal player_lost()

@export_group("Stats & Scaling")
@export var max_hp: float = 100.0
@export var base_damage: float = 10.0
## Erhöht den Schaden additiv um diesen Prozentsatz pro zusätzlichem Level
## Momentan je Level 10 %
@export var damage_modifier_per_level: float = 0.10 
@export var level: int = 1:
	set(value):
		level = maxi(1, value)
@export var move_speed: float = 90.0

@export_group("Combat Configuration")
@export var combat_type: CombatType = CombatType.MELEE
@export var attack_cooldown: float = 1.0
@export var melee_range: float = 40.0
@export var ranged_range: float = 220.0
@export var projectile_scene: PackedScene

var current_hp: float
var target_player: CharacterBody2D = null
var wander_direction: Vector2 = Vector2.ZERO
var wander_change_time: float = 2.0
var wander_timer: float = 0.0

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	current_hp = max_hp
	attack_timer.wait_time = attack_cooldown

	## Signal-Verbindungen für Spielererkennung
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	player_detected.connect(_on_player_detected)
	player_lost.connect(_on_player_lost)

	_pick_new_wander_direction()

# <--Generelle Gegnersteuerung, Erstellung und Einstellung. >

## Steuerung des Gegnermoduses, je nach Angriff oder wandern.
func _physics_process(delta: float) -> void:
	if target_player:
		_process_chase_and_combat()
	else:
		_process_wandering(delta)

	move_and_slide()

	if not target_player and is_on_wall():
		wander_direction = wander_direction.bounce(get_wall_normal()).normalized()


## Gegnererstellung über den Ingamegenerator
func setup(hp: float, start_level: int, type: CombatType) -> void:
	max_hp = hp
	current_hp = hp
	level = start_level
	combat_type = type


## Schadensberechnung mit Level-Modifier, je nach Gegnerstärke
func get_damage() -> float:
	var multiplier: float = 1.0 + (float(level - 1) * damage_modifier_per_level)
	return base_damage * multiplier

## Schadens und Restlebensberechnung des Gegners
func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0.0:
		die()

## Gegner stirbt.
func die() -> void:
	queue_free()


# <--Bewegung- & Patrolsteuerung des Gegners >

func _process_wandering(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_wander_direction()

	velocity = wander_direction * move_speed

## Wahl einer neuen Bewegungsrichtung durch den Gegner.
func _pick_new_wander_direction() -> void:
	wander_timer = randf_range(1.5, wander_change_time)
	var angle: float = randf_range(0.0, TAU)
	wander_direction = Vector2(cos(angle), sin(angle)).normalized()


# <--Kampflogik >

## Beginn der Verfolgung und des Angriffs
func _process_chase_and_combat() -> void:
	var distance_to_player: float = global_position.distance_to(target_player.global_position)
	var attack_threshold: float = melee_range if combat_type == CombatType.MELEE else ranged_range
	var direction_to_player: Vector2 = (target_player.global_position - global_position).normalized()

	if distance_to_player > attack_threshold:
		velocity = direction_to_player * move_speed
	else:
		velocity = Vector2.ZERO
		_try_attack()

## Gegner attackiert, versucht es zumindest ;)
func _try_attack() -> void:
	if not attack_timer.is_stopped():
		return

	attack_timer.start()
	var dmg: float = get_damage()

	match combat_type:
		CombatType.MELEE:
			_execute_melee_attack(dmg)
		CombatType.RANGED:
			_execute_ranged_attack(dmg)

## Führe einen Nahkampfangriff aus.
func _execute_melee_attack(dmg: float) -> void:
	if target_player and target_player.has_method("take_damage"):
		target_player.take_damage(dmg)

## Führe einen Fernkampfangriff aus.
func _execute_ranged_attack(dmg: float) -> void:
	if not projectile_scene:
		return

	var projectile: Node2D = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	var shoot_dir: Vector2 = (target_player.global_position - global_position).normalized()
	if projectile.has_method("init_projectile"):
		projectile.init_projectile(shoot_dir, dmg)
	get_tree().current_scene.add_child(projectile)


# <--Signal-Handling >

## Gegner hat Spieler gefunden. :(
func _on_detection_area_body_entered(body: Node2D) -> void:
	player_detected.emit(body as CharacterBody2D)

## Gegner hat Spieler verloren. :)
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target_player:
		player_lost.emit()

## Setze den target-player auf den gefundenen Spieler.
func _on_player_detected(player: CharacterBody2D) -> void:
	target_player = player

## Entferne den Spieler, weil Spieler verloren und starte wieder zu wandern.
func _on_player_lost() -> void:
	target_player = null
	_pick_new_wander_direction()
