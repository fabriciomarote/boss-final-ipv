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
signal dead()
signal grounded_change(is_grounded)
signal sliding_change(is_sliding)

const FLOOR_NORMAL: Vector2 = Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 32.0
const SLOPE_THRESHOLD: float = deg2rad(46)

const attackModes = preload("res://src/entities/AttackModes.gd")
onready var weapon_tip: Node2D = $WeaponTip
onready var fx_anim: AnimationPlayer = $FXAnim
onready var body_animations: AnimationPlayer = $BodyAnimations
onready var body_pivot: Node2D = $BodyPivot
onready var floor_raycasts: Array = $FloorRaycasts.get_children()
onready var object_check = $BodyPivot/Body/ObjectCheck
## Estas variables de exportación podríamos abstraerlas a cada
## estado correspondiente de la state machine, pero como queremos
## poder modificar estos valores desde afuera de la escena del Player,
## los exponemos desde el script de Player.
export (float) var ACCELERATION: float = 60.0
export (float) var H_SPEED_LIMIT: float = 500.0
export (int) var jump_speed: int = 300
export (float) var FRICTION_WEIGHT: float = 0.1
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
var arrowAmount: int = 0
var lifeAmount: int = 3
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
	#weapon.projectile_container = projectile_container
	attackHandler = attackHandlers.get(attackModes.AXE)
	currentAttackMode = attackModes.AXE


func fire() -> void:
	if !fx_anim.is_playing(): #and contiene flecha:
		## Mato al tween antes de disparar para que no me cambie la rotación
		if fire_tween != null:
			fire_tween.kill()
		
		## No disparo de inmediato, sino que delego a una animación de disparo
		fx_anim.play("fire")
		subtract_arrow_quantity()

## La animación de disparo llama a esta función que va a ser la que instancie
## el proyectil
func _fire() -> void:
	var direction: Vector2 = weapon_tip.global_position
	projectile_scene.instance().initialize(
		self.projectile_container,
		weapon_tip.global_position,
		direction
	)
	
	## Y por último animo el retorno a la posición de inicio del arma
	fire_tween = create_tween()
	
	## Cálculo del demonio, podría haber sido mucho más sencillo utilizando
	## vectores y sacando los ángulos circulares.
	## Lo que hace es toma el ángulo relativo más cercano, ya que después de cierto
	## punto, en vez de rotar correctamente hacia arriba, da toda la vuelta.
#	var final_angle: float = deg2rad(-90.0 + 360.0 * float(rotation > deg2rad(90)))
	
	## Me enculé y lo hice de esta manera. Parece chino también, pero básicamente
	## toma un vector con rotación 0 (los radianes SIEMPRE toman como rotación 0
	## mirar a la izquierda, osea, (1, 0)) y le aplica la rotación actual, le pide el ángulo
	## hacia la dirección que queremos que vaya, y luego se lo suma a la rotación actual.
	var final_angle: float = rotation + Vector2.LEFT.rotated(rotation).angle_to(Vector2.DOWN)
	
	## Y acá se anima programáticamente utilizando el ángulo actual del arma hacia
	## el ángulo final al que debe rotar.
	fire_tween.tween_property(self, "rotation", final_angle, 0.5).set_delay(0.5)

func subtract_arrow_quantity() -> void:
	if arrowAmount == 0:
		arrowAmount = 0
		print("no se descuenta")
	else:
		arrowAmount -= 1
		print("se descuenta")

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
	print(attackHandlers)


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
	subtract_arrow_quantity()

## Y acá se maneja el hit final. Como aun no tenemos una "cantidad" de HP,
## sino una flag, el hit nos mata instantaneamente y tiramos una notificación.
## Esta signal tranquilamente podría llamarse "dead", pero como esa la utilizamos
## para otras cosas, y como sabemos que incorporaremos una barra de salud después
## es apropiado manejarlo de esta manera.
func _handle_hit(amount: int = 1) -> void:
	dead = true
	emit_signal("hp_changed", 0, 1)


# El llamado a remove final
func _remove() -> void:
	set_physics_process(false)
	collision_layer = 0


func handle_arrow() -> void:
	arrowAmount += 1
	print(arrowAmount)


func handle_Life() -> void:
	lifeAmount += 1

func handle_velocity() -> void:
	lifeAmount += 1

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
