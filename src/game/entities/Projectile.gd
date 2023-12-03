extends Node2D
class_name Proyectil

onready var lifetime_timer: Timer = $LifetimeTimer
onready var hitbox: Area2D = $Hitbox
onready var projectile_animations: AnimationPlayer = $ProjectileAnimations

export (float) var VELOCITY: float = 600.0

var direction: Vector2


func initialize(container: Node, spawn_position: Vector2, direction2: Vector2) -> void:
	container.add_child(self)
	self.direction = direction2
	global_position = spawn_position
	rotation = direction2.angle()
	lifetime_timer.connect("timeout", self, "_on_lifetime_timer_timeout")
	lifetime_timer.start()


func _physics_process(delta: float) -> void:
	position += direction * VELOCITY * delta


func _on_lifetime_timer_timeout() -> void:
	remove()

func remove() -> void:
	hitbox.collision_mask = 0
	set_physics_process(false)
	
	## Acá, como hicimos con Turret y Player, delegamos la "muerte"
	## a una animación de golpe.
	projectile_animations.play("hit")


## Esta función se llamaría desde "hit" al terminar la animación
func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.has_method("notify_hit") && !body.protection_actived:
		body.notify_hit(1)
	if body.has_method("notify_hit_protection") && body.protection_actived:
		body.notify_hit_protection()
	remove()

