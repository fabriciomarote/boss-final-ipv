extends AbstractEnemyState

func enter() -> void:
	#character.velocity = Vector2.ZERO
	fire()


func fire() -> void:
	character._play_animation("attack")
	character._fire()


func update(delta:float) -> void:
	character._look_at_target()
	character._handle_deacceleration(delta)
	character._apply_movement()


func _on_animation_finished(anim_name: String) ->  void:
	if character.target == null:
		emit_signal("finished", "idle")
	else:
		match anim_name:
			"attack":
				character._play_animation("alert")
			"alert":
				if character._can_see_target():
					fire()
				else:
					emit_signal("finished", "idle")


func _handle_body_exited(node: Node) -> void:
	._handle_body_exited(node)
	if character.target == null:
		if character.get_current_animation() != "attack":
			emit_signal("finished", "idle")


func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")
