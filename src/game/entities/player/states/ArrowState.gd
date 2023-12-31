extends AbstractState

export (int) var attacks_limit: int = 1

var attacks = 0

func enter() -> void:
	character._shader_hojas(false)
	character._shader_dust(false)
	if character.is_on_floor():
		if character.arrowAmount == 0:
			character._play_animation("whitoutArrow")
		else:
			character._play_animation("arrow")
	else:
		if character.arrowAmount > 0:
			character._play_animation("arrowJump")
			
		else:
			character._play_animation("whitoutArrowJump")
			attacks += 1 


func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("attack") && character.attackHandler == "BowAttack":
		if !character.is_on_floor() && attacks < attacks_limit:
			character._play_animation("arrowJump")


func exit() -> void:
	attacks = 0


# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
			if character.dead:
				emit_signal("finished", "dead")


func _on_animation_finished(_anim_name:String) -> void:
		emit_signal("finished", "idle")	
	
