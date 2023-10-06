extends AbstractState

var hit = 0

# Al entrar se activa primero la animación "attackSword"
func enter() -> void:
	#character.snap_vector = Vector2.ZERO
	do_hit()

func exit() -> void:
	hit = 0

func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("attackArrow"):
		emit_signal("finished", "attackArrow")
	if event.is_action_pressed("idle"):
		emit_signal("finished","idle")
	if event.is_action_pressed("jump") && character.is_on_floor():
		emit_signal("finished", "jump")
	if event.is_action_pressed("attackSword") && hit < 1:
		hit += 1
		do_hit()

func do_hit() -> void: 
	character._play_animation("attackSword")

func update(delta: float) -> void:
	# Vamos a permitir detectar inputs de movimiento
	character._handle_move_input()
	# Para chequear si se realiza un movimiento
	if character.move_direction != 0:
		# Y cambiamos el estado a walk
		emit_signal("finished", "walk")
	else:
		character._apply_movement()
	if hit == 1:
		exit()
		character._play_animation("idle")
		# Y aplicamos la animación apropiada, ya sea idle o saltar/caer
		
		#	character._play_animation("idle")
		#else:
	#if character.velocity.y > 0:
		#		character._play_animation("fall")
		#	else:
	#	character._play_animation("jump")

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")
