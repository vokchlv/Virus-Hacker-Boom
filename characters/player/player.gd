extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal processing_power_changed(current_processing_power: int, max_processing_power: int)

@export var max_health: int = 5
var current_health: int

@export var max_processing_power: int = 5
var current_processing_power: int

@export var speed: float = 150.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	current_health = max_health
	current_processing_power = max_processing_power

func take_damage(amount: int) -> void:
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
func heal(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
func charge(amount: int) -> void:
	current_processing_power = clampi(current_processing_power + amount, 0, max_processing_power)
	processing_power_changed.emit(current_processing_power, max_processing_power)
	
func discharge(amount: int) -> void:
	current_processing_power = clampi(current_processing_power - amount, 0, max_processing_power)
	processing_power_changed.emit(current_processing_power, max_processing_power)

func _physics_process(delta: float) -> void:
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move_direction != Vector2.ZERO:
		animated_sprite.play("running")
		velocity.x = speed * move_direction.x
		velocity.y = speed * 0.6 * move_direction.y
	else:
		animated_sprite.play("idle")
		# decelerate velocity to zero smoothly aka sliding after walking
		velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)
		velocity.y = move_toward(velocity.y, 0, speed * 4 * delta)
	move_and_slide()
