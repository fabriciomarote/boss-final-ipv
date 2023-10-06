extends AbstractState


# Al entrar se activa primero la animación "attackArrow"
func enter() -> void:
	character._play_animation("attackArrow")

func exit() -> void:
	pass

func handle_input(event:InputEvent) -> void:
	character._handle_attackArrow()

func update(delta: float) -> void:
	pass

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")
