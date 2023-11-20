extends KinematicBody2D
class_name EnemyShadow

signal hit(amount)
signal hp_changed(hp, max_hp)

onready var fire_position: Node2D = $FirePosition
onready var raycast: RayCast2D = $RayCast2D
onready var body_anim: AnimatedSprite = $Body
onready var hp_progress: ProgressBar = $HpProgress
onready var particles_2d: Particles2D = $Particles2D
onready var shadow_sfx: AudioStreamPlayer = $ShadowSfx

export (float) var pathfinding_step_threshold:float = 5.0

export (Vector2) var wander_radius: Vector2 = Vector2(10.0, 10.0)
export (float) var speed:float  = 30.0
export (float) var max_speed:float = 100.0
export (AudioStream) var death_sfx

export (PackedScene) var projectile_scene: PackedScene

export (NodePath) var pathfinding_path: NodePath
onready var pathfinding: PathfindAstar = get_node_or_null(pathfinding_path)

export (float) var FRICTION_WEIGHT: float = 6.25

var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO

export (int) var max_hp: int = 10
var hp: int = max_hp

var dead: bool = false


func _ready() -> void:
	hp_progress.max_value = max_hp
	hp_progress.value = hp
	hp_progress.modulate = Color.transparent


func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container
	

func _fire() -> void:
	if target != null:
		var proj_instance: Node = projectile_scene.instance()
		
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(
			projectile_container,
			fire_position.global_position,
			fire_position.global_position.direction_to(target.global_position)
		)


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


func notify_hit(amount: int) -> void:
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
	particles_2d.queue_free()
	get_parent().remove_child(self)
	queue_free()


func _play_animation(animation: String) -> void:
	if body_anim.frames.has_animation(animation):
		body_anim.play(animation)


func get_current_animation() -> String:
	return body_anim.animation


func _death_audio():
	shadow_sfx.stream = death_sfx
	shadow_sfx.play() 
