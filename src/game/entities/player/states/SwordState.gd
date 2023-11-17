extends AbstractState 


func enter() -> void:
	if !character.is_on_floor():
		character._play_animation("axeJump")
	else:
		character._play_animation("axe")


func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")


func _on_animation_finished(_anim_name:String) -> void:
	emit_signal("finished", "idle")	
