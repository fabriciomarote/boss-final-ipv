extends KinematicBody2D
class_name EnemyFlying

signal hit(amount)
onready var ray_cast_2d: RayCast2D = $RayCast2D

onready var body_animation: AnimationPlayer = $BodyAnimation

export (Vector2) var wander_radius: Vector2 = Vector2(10.0, 10.0)
export (float) var speed:float  = 30.0
export (float) var max_speed:float = 100.0


var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO


## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container


func _apply_movement() -> void: 	
	velocity = move_and_slide(velocity, Vector2.UP)


## Esta función ya no llama directamente a remove, sino que inhabilita las
## colisiones con el mundo, pausa todo lo demás y ejecuta una animación de muerte
## dependiendo de si el enemigo esta o no alerta
func notify_hit(amount:int = 1) -> void:
	emit_signal("hit", amount)


func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()

## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_animation.has_animation(animation):
		body_animation.play(animation)

func get_current_animation() -> String:
	return body_animation.current_animation
