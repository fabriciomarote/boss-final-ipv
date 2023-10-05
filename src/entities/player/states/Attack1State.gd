extends AbstractState


# Al entrar se activa primero la animación "attackSword"
func enter() -> void:
	character._play_animation("attackSword")

func exit() -> void:
	pass

func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("attackSword"):
		do_attack()

func do_attack() -> void: 
	character._play_animation("attackSword")

func update(delta: float) -> void:
	pass

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")
