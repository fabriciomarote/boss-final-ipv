extends AbstractState

func enter() -> void:
	if character.is_on_floor():
		character._play_animation("arrow")
	else:
		character._play_animation("arrowJump")
	#character.fire()

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name:String) -> void:
	emit_signal("finished", "idle")
