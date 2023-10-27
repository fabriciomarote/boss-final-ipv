extends KinematicBody2D
class_name EnemySprout

signal hit(amount)
signal hp_changed(hp, max_hp)

onready var raycast: RayCast2D = $RayCast2D
onready var body_anim: AnimatedSprite = $Body
onready var hp_progress: ProgressBar = $HpProgress

export (float) var pathfinding_step_threshold:float = 5.0

export (Vector2) var wander_radius: Vector2 = Vector2(10.0, 10.0)
export (float) var speed:float  = 30.0
export (float) var max_speed:float = 100.0

export (NodePath) var pathfinding_path: NodePath
onready var pathfinding: PathfindAstar = get_node_or_null(pathfinding_path)

var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO

export (int) var max_hp: int = 2
var hp: int = max_hp

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func _ready() -> void:
	hp_progress.max_value = max_hp
	hp_progress.value = hp
	#hp_progress.modulate = Color.transparent


func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container
	

func _fire() -> void:
	pass
	

func _look_at_target() -> void:
	body_anim.flip_h = raycast.cast_to.x < 0


func _can_see_target() -> bool:
	if target == null:
		return false
	raycast.set_cast_to(raycast.to_local(target.global_position))
	raycast.force_raycast_update()
	return raycast.is_colliding() && raycast.get_collider() == target


func _apply_movement() -> void: 	
	velocity = move_and_slide(velocity, Vector2.UP)


## Esta función ya no llama directamente a remove, sino que inhabilita las
## colisiones con el mundo, pausa todo lo demás y ejecuta una animación de muerte
## dependiendo de si el enemigo esta o no alerta
func notify_hit(amount:int = 1) -> void:
	emit_signal("hit", amount)

var hp_tween: SceneTreeTween

func _sum_hp(amount: int) -> void:
	hp = clamp(hp + amount, 0, max_hp)
	hp_progress.max_value = max_hp
	hp_progress.value = hp
	emit_signal("hp_changed", hp, max_hp)
	
	if hp_tween:
		hp_tween.kill()
	hp_tween = create_tween()
	hp_progress.modulate = Color.white
	hp_tween.tween_property(hp_progress, "modulate", Color.transparent, 5.0)


func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()

## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_anim.frames.has_animation(animation):
		body_anim.play(animation)

func get_current_animation() -> String:
	return body_anim.animation
