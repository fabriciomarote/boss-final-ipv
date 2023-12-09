extends AbstractState 


func enter() -> void:
	character._shader_hojas(false)
	character._shader_dust(false)
	if !character.is_on_floor():
		character._attack_audio()
		character._play_animation("axeJump")
	else:
		character._attack_audio()
		character._play_animation("axe")
		


func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
			if character.dead:
				emit_signal("finished", "dead")


func _on_animation_finished(_anim_name:String) -> void:
	emit_signal("finished", "idle")	
