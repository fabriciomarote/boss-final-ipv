extends KinematicBody2D
class_name Player

## Señales que sirven para comunicar el estado del Player
## a los elementos conectados. Se puede utilizar tanto para
## comunicar estados a la State Machine (sin incluir código
## de la state machine directamente) como para comunicarse,
## por ejemplo, con el entorno del nivel.
signal hit(amount)
signal healed(amount)
signal hp_changed(current_hp, max_hp)
signal stamina_changed(current_stamina, max_stamina)
signal protection_changed(current_protection, max_protection)
signal weapon_changed(weapon)
signal arrow_changed(amount)
signal dead()
signal damage()

signal grounded_change(is_grounded)
signal sliding_change(is_sliding)

const FLOOR_NORMAL: Vector2 = Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 35.0
const SLOPE_THRESHOLD: float = deg2rad(46)

const attackModes = preload("res://src/game/entities/AttackModes.gd")

onready var weapon_tip: Node2D = $"%WeaponTip"
onready var body_animations: AnimationPlayer = $BodyAnimations
onready var body_pivot: Node2D = $BodyPivot
onready var floor_raycasts: Array = $FloorRaycasts.get_children()
onready var object_check = $BodyPivot/Body/ObjectCheck
onready var sprite: Sprite = $BodyPivot/WeaponTip/Sprite
onready var player_sfx: AudioStreamPlayer = $PlayerSfx
onready var protection_area: KinematicBody2D = $BodyPivot/Protection
onready var color_rect: ColorRect = $BodyPivot/ProtectionArea/ColorRect
onready var collision_shape: CollisionShape2D = $BodyPivot/ProtectionArea/CollisionShape2D

export (float) var ACCELERATION: float = 500.0
export (float) var H_SPEED_LIMIT: float = 10.0
export (int) var jump_speed: int = 360
export (float) var FRICTION_WEIGHT: float = 5.0
export (int) var gravity: int = 20
export (AudioStream) var jump_sfx
export (AudioStream) var walk_sfx
export (AudioStream) var dash_sfx
export (AudioStream) var death_sfx
export (AudioStream) var damage_sfx
export (PackedScene) var projectile_scene: PackedScene 

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
var arrowAmount: int = 10
var is_attacked = false
var protection_actived = false

export (int) var max_hp: int = 5
var hp: int = max_hp

export (int) var max_protection: int = 3
var protection: int = 0

export (float) var max_stamina: float = 10.0
var stamina: float = 0.0

export (float) var stamina_recovery_time: float = 5.0
export (float) var stamina_recovery_delay: float = 0.5

var fire_tween: SceneTreeTween

var dead: bool = false
func _ready() -> void:
	initialize()


func initialize(projectile_container: Node = get_parent()) -> void:
	attackHandlers = {
		attackModes.AXE: "AxeAttack",
		attackModes.BOW: "BowAttack"
	}
	
	self.projectile_container = projectile_container
	attackHandler = attackHandlers.get(attackModes.BOW)
	currentAttackMode = attackModes.BOW
	emit_signal("weapon_changed", currentAttackMode)
	GameState.set_current_player(self)


func fire() -> void:
	if !body_animations.is_playing(): #and contiene flecha:
		## Mato al tween antes de disparar para que no me cambie la rotación
		if fire_tween != null:
			fire_tween.kill()


## La animación de disparo llama a esta función que va a ser la que instancie
## el proyectil
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


func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0


func move_is_attackingAxe() -> void:
	print(body_pivot.scale.x)
	if move_direction > 0 || (move_direction == 0 && body_pivot.scale.x > 0):
		move_direction = 5
	if move_direction < 0 || (move_direction == 0 && body_pivot.scale.x < 0):
		move_direction -5
	velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
	body_pivot.scale.x = 1 - 2 * float(move_direction < 0)


func move_is_attackingBow() -> void:
	print(body_pivot.scale.x)
	if !is_on_floor() || (move_direction == 0 && body_pivot.scale.x > 0):
		move_direction = -5
	if !is_on_floor() || (move_direction == 0 && body_pivot.scale.x < 0):
		move_direction = -10
	velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
	body_pivot.scale.x = 1 - 2 * float(move_direction < 0)


func is_near_wall():
	return object_check.is_colliding()


func is_sliding():
	if  !is_near_wall() && floor_raycasts[0].is_colliding() && !floor_raycasts[1].is_colliding() && floor_raycasts[2].is_colliding():
		return 1
	if !is_near_wall() && !floor_raycasts[0].is_colliding() && floor_raycasts[1].is_colliding() && floor_raycasts[2].is_colliding():
		return -1
	else:
		return 0 


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
		print("no se descuenta")
	else:
		arrowAmount -= 1
		print("se descuenta")
	emit_signal("arrow_changed", arrowAmount)


func _apply_movement(with_gravity: bool = true) -> void:
	velocity.y += gravity * float(with_gravity)
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, stop_on_slope, 4, SLOPE_THRESHOLD)
	if is_on_floor() && snap_vector == Vector2.ZERO:
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH


func is_on_floor() -> bool:
	var is_colliding: bool = .is_on_floor()
	for raycast in floor_raycasts:
		## Al tener deshabilitados los raycasts por default
		## ya que queremos que solamente se procesen en esta
		## función, debemos forzar una actualización
		raycast.force_raycast_update()
		is_colliding = is_colliding || raycast.is_colliding()
	return is_colliding


func notify_hit(amount: int = 1) -> void:
	emit_signal("hit", amount)


func notify_hit_protection(amount: int = 1) -> void:
	print(protection)
	protection -= 1
	if protection == 0:
		protection_actived = false
		_protection_disabled()  
	else: 
		true
	emit_signal("protection_changed", amount)


func notify_heal(amount: int = 1) -> void:
	emit_signal("healed", amount)


func notify_dead() -> void:
	hp = 0
	emit_signal("hp_changed", hp, max_hp)


func sum_hp() -> void:
	hp += 1
	emit_signal("hp_changed", hp, max_hp)


func sum_stamina() -> void:
	stamina = max_stamina
	emit_signal("stamina_changed", stamina, max_stamina)


func sum_protection() -> void:
	protection = max_protection
	emit_signal("protection_changed", protection, max_protection)


var stamina_regen_tween: SceneTreeTween

#func sum_stamina(amount: float) -> void:
	#_update_passive_prop(
	#	clamp(stamina + amount, 0.0, max_stamina),
	#	max_stamina,
	#	"stamina",
	#	"stamina_changed"
	#)
	#if stamina < max_stamina:
	#	if stamina_regen_tween:
	#		stamina_regen_tween.kill()
	#	stamina_regen_tween = create_tween()
	#	var duration: float = (max_stamina - stamina) * stamina_recovery_time / max_stamina
	#	stamina_regen_tween.tween_method(
	#		self,
	#		"_update_passive_prop",
	#		stamina,
	#		max_stamina,
	#		duration,
	#		[max_stamina, "stamina", "stamina_changed"]
	#	).set_delay(stamina_recovery_delay)

func _update_passive_prop(amount, max_amount, property: String, updated_signal) -> void:
	set(property, amount)
	emit_signal(updated_signal, amount, max_amount)


func _handle_hit_protection(amount: int) -> void:
	print(protection)
	protection -= 1
	if protection == 0:
		protection_actived = false
		_protection_disabled()  
	else: 
		true
	emit_signal("protection_changed", amount)


func _handle_hit(amount: int) -> void:
	hp = max(0, hp - amount)
	dead = true if hp == 0 else false
	emit_signal("hp_changed", hp, max_hp)


func _remove() -> void:
	set_physics_process(false)
	collision_layer = 0


func handle_velocity() -> void:
	if stamina == 10:
		self.ACCELERATION = 100
		self.H_SPEED_LIMIT = 450


func _protection_active():
	print(protection)
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


func _on_CutArea_body_entered(body):
	body.notify_hit(3)


func _walk_audio():
	player_sfx.stream = walk_sfx
	player_sfx.play() 


func _jump_audio():
	player_sfx.stream = jump_sfx
	player_sfx.play() 


func _on_ProtectionArea_body_entered(body):
	print("hola")
