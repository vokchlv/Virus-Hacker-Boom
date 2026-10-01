"""
Erstellung und Verwaltung der Projektile eines Gegners.
Layer: 4 Projectile
Mask: 1 (World) / 2 (Player)
"""
class_name Projectile
extends Area2D

@export var speed: float = 300.0
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.ZERO
var damage: float = 0.0

func _ready() -> void:
	# Kollisionen verbinden
	body_entered.connect(_on_body_entered)
	
	# Automatisches Löschen außerhalb des Sichtfelds
	var screen_notifier: VisibleOnScreenNotifier2D = get_node_or_null("VisibleOnScreenNotifier2D")
	if screen_notifier:
		screen_notifier.screen_exited.connect(queue_free)
	
	# Fallback-Timer gegen Speicherlecks, falls der Spieler weit weg ist
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


## Wird vom Enemy-Script beim Spawnen aufgerufen
func init_projectile(shoot_dir: Vector2, dmg: float) -> void:
	direction = shoot_dir.normalized()
	damage = dmg
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
