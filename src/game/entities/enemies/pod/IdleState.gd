extends AbstractEnemyState

func enter() -> void:
	character.velocity = Vector2.ZERO
	character._play_animation("idle")
	
	
func update(delta:float) -> void:
	character._apply_movement()
	if character._can_see_target():
		emit_signal("finished", "alert")
