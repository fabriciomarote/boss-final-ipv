extends AbstractState

const attackModes = preload("res://src/game/entities/AttackModes.gd")


func enter() -> void:
	print(character)
	character._play_animation("idle")
	character.emit_signal("grounded_change",true)


func handle_input(event: InputEvent) -> void:
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
	
	# Vamos a permitir detectar inputs de movimiento
	character._handle_move_input()
	# Para chequear si se realiza un movimiento
	if character.move_direction != 0:
		# Y cambiamos el estado a walk
		emit_signal("finished", "walk")
	else:
		# Si no se realiza movimiento, desaceleramos y manejamos movimiento
		character._handle_deacceleration()
		character._apply_movement()
		
		# Y aplicamos la animación apropiada, ya sea idle o saltar/caer
		if character.is_on_floor():
			character._play_animation("idle")
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

