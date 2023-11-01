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
signal arrow_changed(amount)
signal weapon_changed(weapon)
signal dead()

signal grounded_change(is_grounded)
signal sliding_change(is_sliding)

const FLOOR_NORMAL: Vector2 = Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 32.0
const SLOPE_THRESHOLD: float = deg2rad(46)

const attackModes = preload("res://src/game/entities/AttackModes.gd")

onready var weapon_tip: Node2D = $"%WeaponTip"
onready var body_animations: AnimationPlayer = $BodyAnimations
onready var body_pivot: Node2D = $BodyPivot
onready var floor_raycasts: Array = $FloorRaycasts.get_children()
onready var object_check = $BodyPivot/Body/ObjectCheck

export (float) var ACCELERATION: float = 60.0
export (float) var H_SPEED_LIMIT: float = 500.0
export (int) var jump_speed: int = 300
export (float) var FRICTION_WEIGHT: float = 6.25
export (int) var gravity: int = 10
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
var arrowAmount: int = 5
export (int) var max_hp: int = 5
var hp: int = max_hp

var fire_tween: SceneTreeTween

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false
func _ready() -> void:
	initialize()

func initialize(projectile_container: Node = get_parent()) -> void:
	attackHandlers = {
		attackModes.AXE: "AxeAttack",
		attackModes.BOW: "BowAttack"
	}
	
	self.projectile_container = projectile_container
	attackHandler = attackHandlers.get(attackModes.AXE)
	currentAttackMode = attackModes.AXE
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

func subtract_arrow_quantity() -> void:
	if arrowAmount == 0:
		arrowAmount = 0
	else:
		arrowAmount -= 1
	emit_signal("arrow_changed", arrowAmount)

## Se extrae el comportamiento del manejo del movimiento horizontal
## a una función para ser llamada apropiadamente desde la state machine
func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
		body_pivot.scale.x = 1 - 2 * float(move_direction < 0)

## Se extrae el comportamiento del manejo de la aplicación de fricción
## a una función para ser llamada apropiadamente desde la state machine
func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

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


## Se extrae el comportamiento de la aplicación de gravedad y movimiento
## a una función para ser llamada apropiadamente desde la state machine
func _apply_movement() -> void:
	velocity.y += gravity
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, stop_on_slope, 4, SLOPE_THRESHOLD)
	if is_on_floor() && snap_vector == Vector2.ZERO:
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH


## Función que pisa la función is_on_floor() ya existente
## y le agrega el chequeo de raycasts para expandir la ventana
## de chequeo de piso
func is_on_floor() -> bool:
	var is_colliding: bool = .is_on_floor()
	for raycast in floor_raycasts:
		## Al tener deshabilitados los raycasts por default
		## ya que queremos que solamente se procesen en esta
		## función, debemos forzar una actualización
		raycast.force_raycast_update()
		is_colliding = is_colliding || raycast.is_colliding()
	return is_colliding

## Esta función ya no llama directamente a remove, sino que deriva
## el handleo a la state machine emitiendo una señal. Esto es para
## los casos de estados en los cuales no se manejan hits
func notify_hit(amount: int = 1) -> void:
	emit_signal("hit", amount)


func notify_dead() -> void:
	hp = 0
	emit_signal("hp_changed", hp, max_hp)


func sum_hp(amount: int) -> void:
	hp = clamp(hp + 1, 0, max_hp)
	emit_signal("hp_changed", hp, max_hp)


func _handle_hit(amount: int) -> void:
	hp = max(0, hp - amount)
	dead = true if hp == 0 else false
	emit_signal("hp_changed", hp, max_hp)


# El llamado a remove final
func _remove() -> void:
	set_physics_process(false)
	collision_layer = 0


func handle_arrow() -> void:
	arrowAmount += 1
	emit_signal("arrow_changed", arrowAmount)


func handle_Life() -> void:
	pass
	#lifeAmount += 1

func handle_velocity() -> void:
	print("corre")
	ACCELERATION = 400
   #lifeAmount += 1

## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation)


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
	body.notify_hit()
