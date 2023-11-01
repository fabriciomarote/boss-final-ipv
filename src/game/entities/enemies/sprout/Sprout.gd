extends KinematicBody2D
class_name EnemySprout

signal hit(amount)
signal hp_changed(current_hp, max_hp)

onready var raycast = $Pivot/RayCast2D
onready var body: AnimatedSprite = $Pivot/Body 
onready var pivot = $Pivot
onready var hud = $Pivot/HUD
onready var hp_progress = $Pivot/HUD/Control/HpProgress
onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

export (float) var ACCELERATION: float = 10.0
export (float) var H_SPEED_LIMIT: float = 30.0


export (float) var pathfinding_step_threshold:float = 5.0
export (float) var FRICTION_WEIGHT: float = 6.25
export (Vector2) var wander_radius: Vector2 = Vector2(10.0, 10.0)
export (float) var speed:float  = 30.0
export (float) var max_speed:float = 100.0
export (int) var gravity: int = 10
export (int) var max_hp: int = 3

var hp: int = max_hp
var target: Node2D
var projectile_container: Node
var velocity: Vector2 = Vector2.ZERO
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


func _handle_deacceleration(delta: float) -> void:
	velocity = velocity.linear_interpolate(Vector2.ZERO, FRICTION_WEIGHT * delta)


func apply_movement() -> void:
	velocity = move_and_slide(velocity, Vector2.UP)


func notify_hit(amount:int = 1) -> void:
	print(hp)
	print("disparo recibido")
	_handle_hit(amount)
	emit_signal("hit", amount)

func _handle_hit(amount: int) -> void:
	hp = max(0, hp - amount)
	if hp == 0:
		dead = true 
		_remove() 
	else:
		 false
	emit_signal("hp_changed", hp, max_hp)

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
	if body.frames.has_animation(animation):
		body.play(animation)

func get_current_animation() -> String:
	return body.animation
