extends AbstractState

# Al entrar se activa primero la animación "attackArrow"
func enter() -> void:
	character._handle_weapon_actions()

func handle_input(event:InputEvent) -> void:
	character._play_animation("attackArrow")
	if event.is_action_pressed("attackSword"):
		emit_signal("finished", "attackSword")
	if event.is_action_pressed("jump") && character.is_on_floor():
		emit_signal("finished", "jump")

func update(delta: float) -> void:
	# Vamos a permitir detectar inputs de movimiento
	character._handle_move_input()
	# Para chequear si se realiza un movimiento
	
	if character.move_direction != 0:
		# Y cambiamos el estado a walk
		emit_signal("finished", "walk")
	else:
		character._apply_movement()


# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")
