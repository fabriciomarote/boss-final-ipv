extends AbstractEnemyState

func enter() -> void:
	character.velocity = Vector2.ZERO
	character._play_animation("idle")
	
	
func update(_delta:float) -> void:
	character._apply_movement()
	if character._can_see_target():
		emit_signal("finished", "alert")


func _handle_body_entered(body: Node) -> void:
	._handle_body_entered(body)
	character._play_animation("alert")


func _handle_body_exited(body) -> void:
	._handle_body_exited(body)
	character._play_animation("walk")


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"alert":
			character._play_animation("walk")


func handle_event(event: String, value = null) -> void:
	.handle_event(event,value)
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")
