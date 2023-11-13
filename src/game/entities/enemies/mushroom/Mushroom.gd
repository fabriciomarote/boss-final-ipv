extends KinematicBody2D
class_name EnemyMushroom

export (float) var ACCELERATION: float = 10.0
export (float) var H_SPEED_LIMIT: float = 30.0

const MAX_LIFE = 5

signal hit(amount)

onready var fire_position: Position2D = $Pivot/FirePosition
onready var raycast: RayCast2D = $Pivot/RayCast2D
onready var body_anim: AnimatedSprite = $Pivot/Body
onready var navigation_agent = $NavigationAgent2D
onready var life_progress_bar:ProgressBar = $Pivot/HUD/Control/LifeProgressBar
onready var hud:Node2D = $Pivot/HUD
onready var pivot:Node2D = $Pivot

export (float) var speed:float  = 10.0
export (float) var max_speed:float = 100.0
export (int) var gravity: int = 10
export (int) var life: int = MAX_LIFE
export (PackedScene) var projectile_scene: PackedScene


var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func _ready():
	life_progress_bar.max_value = MAX_LIFE
	life_progress_bar.value = life
	
func _fire() -> void:
	if target != null:
		var proj_instance: Node = projectile_scene.instance()
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(
			projectile_container,
			fire_position.global_position,
			#fire_position.global_position.direction_to(target.global_position)
			fire_position.global_position.direction_to(Vector2(target.global_position.x, fire_position.global_position.y))
		)
	
func _look_at_target() -> void:
	if target != null:
		pivot.scale.x = -1 if target.global_position.x > global_position.x else 1
	else:
		pivot.scale.x = -1 if velocity.x > 0 else 1

func _can_see_target() -> bool:
	if target == null:
		return false
	raycast.set_cast_to(raycast.to_local(target.global_position))
	raycast.force_raycast_update()
	return raycast.is_colliding() && raycast.get_collider() == target
	
	
func _apply_movement() -> void:
	if navigation_agent != null:
		if (target!=null):
			navigation_agent.set_target_location(target.global_position)
	else:
		print("no navigation agent")	
	velocity.y += gravity
	velocity = move_and_slide(velocity)
	_look_at_target()

## Esta función ya no llama directamente a remove, sino que inhabilita las
## colisiones con el mundo, pausa todo lo demás y ejecuta una animación de muerte
## dependiendo de si el enemigo esta o no alerta
func notify_hit(amount:int = 1) -> void:
	emit_signal("hit", amount)

	
func _remove() -> void:
	dead = true
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	for n in get_children():
		remove_child(n)
		n.queue_free()
	get_parent().remove_child(self)
	queue_free()

## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_anim.frames.has_animation(animation):
		body_anim.play(animation)

func get_current_animation() -> String:
	return body_anim.animation
