extends AbstractState


# Al entrar se activa primero la animación "walk"
func enter() -> void:
	character._play_animation("walk")
	character.emit_signal("grounded_change",true)


func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if character.attackHandler == "BowAttack":
			emit_signal("finished", "sword")
		else:
			emit_signal("finished", "arrow")
	if event.is_action_pressed("jump") && character.is_on_floor():
		emit_signal("finished", "jump")
	if event.is_action_pressed("change_attack"):
		character._change_attack_mode()
	if event.is_action_pressed("run"):
		character.handle_velocity()

# En esta función vamos a manejar las acciones apropiadas para este estado
func update(delta: float) -> void:
	# Vamos a querer que se pueda disparar
	#character._handle_weapon_actions()
	
	# Vamos a manejar los inputs de movimiento
	character._handle_move_input()
	# Aplicar ese movimiento, sin desacelerar
	character._apply_movement()
	
	# Y luego chequeamos si se quedó quieto el personaje
	if character.move_direction == 0:
		# Y cambiamos el estado a idle
		emit_signal("finished", "idle")
	else:
		# O aplicamos la animación que corresponde
		if character.is_on_floor():
			character._play_animation("walk")
		else:
			if character.velocity.y > 0:
				character._play_animation("fall")
			else:
				character._play_animation("jump")


# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")

