extends KinematicBody2D
class_name Player

signal hit(amount)
signal hp_changed(current_hp, max_hp)
signal stamina_changed(current_stamina, max_stamina)
signal protection_changed(current_protection, max_protection)
signal weapon_changed(weapon)
signal arrow_changed(amount)
signal deaths_changed(amount)
signal chances_changed(amount)

const FLOOR_NORMAL: Vector2 = Vector2.UP 
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 35.0
const SLOPE_THRESHOLD: float = deg2rad(46)

const attackModes = preload("res://src/game/entities/AttackModes.gd")

onready var weapon_tip: Node2D = $"%WeaponTip"
onready var body_animations: AnimationPlayer = $BodyAnimations
onready var body_pivot: Node2D = $BodyPivot
onready var floor_raycasts: Array = $FloorRaycasts.get_children()
onready var object_check = $BodyPivot/Body/ObjectCheck
onready var player_sfx: AudioStreamPlayer = $PlayerSfx
onready var color_rect: ColorRect = $BodyPivot/ProtectionArea/ColorRect
onready var collision_shape: CollisionShape2D = $BodyPivot/ProtectionArea/CollisionShape2D
onready var particles: Particles2D = $BodyPivot/Particles/Dash
onready var timer: Timer = $"%Timer"

export (float) var ACCELERATION: float = 35.0
export (float) var H_SPEED_LIMIT: float = 45.0
export (int) var jump_speed: int = 300
export (float) var FRICTION_WEIGHT: float = 3.0
export (int) var gravity: int = 13
export (AudioStream) var jump_sfx
export (AudioStream) var walk_sfx
export (AudioStream) var dash_sfx
export (AudioStream) var death_sfx
export (AudioStream) var damage_sfx
export (AudioStream) var handle_life_sfx
export (AudioStream) var handle_mushroom_sfx
export (PackedScene) var projectile_scene: PackedScene 
export(bool) var can_dash : bool #Comprueba si puede hacer el dash

var dash : bool #Comprueba si lo esta haciendo
var projectile_container: Node

var BowAttack: String
var AxeAttack: String
var attackHandler
var attackHandlers
var currentAttackMode
var velocity: Vector2 = Vector2.ZERO
var snap_vector: Vector2 = SNAP_DIRECTION * SNAP_LENGTH
var stop_on_slope: bool = true
var move_direction: int = 0
var hit_Direction : int = 0
var arrowAmount: int = 0
var is_attacked = false
var protection_actived = false
var deaths: int = 10
var chances: int = 3

export (int) var max_hp: int = 10
var hp: int = max_hp

export (int) var max_protection: int = 5
var protection: int = 0

export (float) var max_stamina: float = 10.0
var stamina: float = 0


var fire_tween: SceneTreeTween

var dead: bool = false


func _ready() -> void:
	initialize()


func initialize(_projectile_container: Node = get_parent()) -> void:
	attackHandlers = {
		attackModes.AXE: "AxeAttack",
		attackModes.BOW: "BowAttack"
	}
	self.projectile_container = _projectile_container
	attackHandler = attackHandlers.get(attackModes.AXE)
	currentAttackMode = attackModes.AXE
	emit_signal("weapon_changed", currentAttackMode)
	GameState.set_current_player(self)
	GameState.connect("enemy_dead", self, "_sum_dead")
	GameState.connect("chance_subtract", self, "_chance_changed")


func _sum_dead() -> void:
	deaths += 1
	emit_signal("deaths_changed", deaths)


func _chance_changed() -> void:
	chances -= 1
	emit_signal("chances_changed", chances)


func fire() -> void:
	if !body_animations.is_playing():
		if fire_tween != null:
			fire_tween.kill()


func _fire() -> void:
	var direction: Vector2 = Vector2(round(global_position.direction_to(weapon_tip.global_position).x), 0)
	var proj = projectile_scene.instance()
	proj.initialize(
		self.projectile_container,
		weapon_tip.global_position,
		direction
	)
	subtract_arrow_quantity()


func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		_handle_deacceleration()
		velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
		body_pivot.scale.x = 1 - 2 * float(move_direction < 0)
		
		

func _shader_hojas(boolean: bool) -> void:
	$BodyPivot/Particles/Hojas.emitting = boolean
	
func _shader_dust(boolean: bool) -> void:
	$BodyPivot/Particles/Dust.emitting = boolean

func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0


func _change_attack_mode():
	if Input.is_action_just_pressed("change_attack"):
		if (currentAttackMode == attackModes.BOW):
			attackHandler = attackHandlers.get(attackModes.AXE)
			currentAttackMode = attackModes.AXE
			
		else:
			attackHandler = attackHandlers.get(attackModes.BOW)
			currentAttackMode = attackModes.BOW
	emit_signal("weapon_changed", currentAttackMode)


func subtract_arrow_quantity() -> void:
	if arrowAmount == 0:
		arrowAmount = 0
	else:
		arrowAmount -= 1
	emit_signal("arrow_changed", arrowAmount)


func _apply_movement(with_gravity: bool = true) -> void:
	velocity.y += gravity * float(with_gravity)
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, stop_on_slope, 4, SLOPE_THRESHOLD)
	if is_on_floor() && snap_vector == Vector2.ZERO:
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH


func is_on_floor() -> bool:
	var is_colliding: bool = .is_on_floor()
	for raycast in floor_raycasts:
		raycast.force_raycast_update()
		is_colliding = is_colliding || raycast.is_colliding()
	return is_colliding


func notify_hit(amount: int) -> void:
	emit_signal("hit", amount)


func notify_dead() -> void:
	hp = 0
	dead = true
	emit_signal("hp_changed", hp, max_hp)
	_remove()


func notify_hit_protection(_amount: int = 1) -> void:
	protection -= 1
	if protection == 0:
		protection_actived = false
		_protection_disabled()  
	emit_signal("protection_changed", protection, max_protection)


func sum_hp() -> void:
	hp += 2
	_handle_life_audio()
	emit_signal("hp_changed", hp, max_hp)


func sum_stamina() -> void:
	stamina = max_stamina
	_handle_mushroom_audio()
	emit_signal("stamina_changed", stamina, max_stamina)


func sum_protection() -> void:
	protection = max_protection
	_handle_mushroom_audio()
	emit_signal("protection_changed", protection, max_protection)


func handle_arrow() -> void:
	arrowAmount += 1
	emit_signal("arrow_changed", arrowAmount)


func _handle_hit(amount: int) -> void:
	hp = max(0, hp - amount)
	dead = true if hp == 0 else false
	emit_signal("hp_changed", hp, max_hp)


func _remove() -> void:
	if GameState.chance > 0:
		GameState.chances_subtract()
		get_tree().reload_current_scene()
	else:
		set_physics_process(false)
		collision_layer = 0
	


func handle_velocity() -> void:
	if stamina == max_stamina:
		timer.start()
		self.ACCELERATION = 400
		self.H_SPEED_LIMIT = 400


func _protection_active():
	if hay_escudo_disponible():
		color_rect.visible = true
		collision_shape.disabled = false
		protection_actived = true


func _protection_disabled():
		color_rect.visible = false


func _play_animation(animation: String) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation)


func hay_escudo_disponible() -> bool:
	return protection > 0


func _on_Hitbox_body_entered(body):
	if body.global_position > self.global_position:
		hit_Direction = 1
	else:
		hit_Direction = -1
	notify_hit(1)


func _on_Hitbox_area_entered(area):
	if area.global_position > self.global_position:
		hit_Direction = 1
	else:
		hit_Direction = -1
	notify_hit(1)


func _dash():
	if can_dash and Input.is_action_just_pressed("run"):
		dash = true
		can_dash = false
		$Dash.start()

func _on_CutArea_body_entered(body):
	body.notify_hit(3)


func _walk_audio():
	player_sfx.stream = walk_sfx
	player_sfx.play() 


func _jump_audio():
	player_sfx.stream = jump_sfx
	player_sfx.play() 


func _damage_audio():
	player_sfx.stream = damage_sfx
	player_sfx.play() 


func _handle_life_audio():
	player_sfx.stream = handle_life_sfx
	player_sfx.play() 


func _handle_mushroom_audio():
	player_sfx.stream = handle_mushroom_sfx
	player_sfx.play() 


func _on_CutArea2_body_entered(body):
	body.notify_hit(3)


func _on_Timer_timeout():
	if stamina > 0:
		stamina -= 1
		emit_signal("stamina_changed", stamina, max_stamina)
		if  velocity.x == 0:
			particles.emitting = false
		else:
			particles.emitting = true
	else:
		particles.emitting = false
		timer.stop()
		self.ACCELERATION = 150
		self.H_SPEED_LIMIT = 250
