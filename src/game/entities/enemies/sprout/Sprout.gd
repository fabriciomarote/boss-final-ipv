extends KinematicBody2D
class_name EnemySprout

signal hit(amount)
signal hp_changed(current_hp, max_hp)

onready var fire_position: Position2D = $Pivot/FirePosition
onready var raycast: RayCast2D = $Pivot/RayCast2D
onready var body_anim: AnimatedSprite = $Pivot/Body
onready var navigation_agent = $NavigationAgent2D
onready var hp_progress:ProgressBar = $Pivot/HUD/Control/HpProgress
onready var hud:Node2D = $Pivot/HUD
onready var pivot:Node2D = $Pivot
onready var sprout_sfx: AudioStreamPlayer = $SproutSfx
onready var area_attack = $Pivot/AreaAttack
onready var collision_attack = $Pivot/AreaAttack/CollisionShape2D
onready var timer_activate = $Pivot/AreaAttack/Timer_activate
onready var timer_disable = $Pivot/AreaAttack/Timer_disable

export (int) var gravity: int = 50
export (float) var ACCELERATION: float = 70.0
export (float) var H_SPEED_LIMIT: float = 110.0
export (int) var max_hp: int = 6
var hp: int = max_hp

export (AudioStream) var death_sfx
export (PackedScene) var projectile_scene: PackedScene


var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO

var dead: bool = false


func _ready():
	hp_progress.max_value = max_hp
	hp_progress.value = hp
	hp_progress.modulate = Color.transparent


func _fire() -> void:
	if target != null:
		var proj_instance: Node = projectile_scene.instance()
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(
			projectile_container,
			fire_position.global_position,
			fire_position.global_position.direction_to(Vector2(target.global_position.x, fire_position.global_position.y))
		)


func attack() -> void:
	activate_attack()


func activate_attack() -> void:
	timer_activate.start()


func _on_Timer_activate_timeout():
	collision_attack.disabled = false
	area_attack.visible = true
	disable_attack()
	timer_activate.stop()


func disable_attack() -> void:
	timer_disable.start()


func _on_Timer_disable_timeout():
	collision_attack.disabled = true
	area_attack.visible = false
	timer_disable.stop()


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


func notify_hit(amount:int = 1) -> void:
	emit_signal("hit", amount)


var hp_tween: SceneTreeTween

func _handle_hit(amount: int) -> void:
	hp = max(0, hp - amount)
	hp_progress.max_value = max_hp
	hp_progress.value = hp
	dead = true if hp == 0 else false
	emit_signal("hp_changed", hp, max_hp)
	
	if hp_tween:
		hp_tween.kill()
	hp_tween = create_tween()
	hp_progress.modulate = Color.white
	hp_tween.tween_property(hp_progress, "modulate", Color.transparent, 5.0)


func _remove() -> void:
	GameState.notify_dead()
	dead = true
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	for n in get_children():
		remove_child(n)
		n.queue_free()
	get_parent().remove_child(self)
	queue_free()


func _play_animation(animation: String) -> void:
	if body_anim.frames.has_animation(animation):
		body_anim.play(animation)


func get_current_animation() -> String:
	return body_anim.animation


func _death_audio():
	sprout_sfx.stream = death_sfx
	sprout_sfx.play() 


func _on_AreaAttack_body_entered(body):
	if !collision_attack.disabled:
		if body is Player:
			if body.has_method("notify_hit") && !body.protection_actived:
				body.notify_hit(2)
			if body.has_method("notify_hit_protection") && body.protection_actived:
				body.notify_hit_protection()

