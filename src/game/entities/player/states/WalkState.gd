extends AbstractState


func enter() -> void:
	character._play_animation("walk")


func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if character.attackHandler == "BowAttack":
			emit_signal("finished", "arrow")
		else:
			emit_signal("finished", "sword")
	if event.is_action_pressed("jump") && character.is_on_floor():
		emit_signal("finished", "jump")
	if event.is_action_pressed("change_attack"):
		character._change_attack_mode()
	if event.is_action_pressed("run"):
		character.handle_velocity()
	if event.is_action_pressed("protection"):
		character._protection_active()


func update(_delta: float) -> void:
	character._handle_move_input()
	character._apply_movement()
	
	if character.move_direction == 0:
		emit_signal("finished", "idle")
	else:
		if character.is_on_floor():
			character._play_animation("walk")
		else:
			if character.velocity.y > 0:
				character._play_animation("fall")
			else:
				character._play_animation("jump")


func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
			if character.dead:
				emit_signal("finished", "dead")

