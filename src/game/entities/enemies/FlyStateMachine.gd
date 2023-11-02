extends AbstractStateMachine
class_name FlyStateMachine

func _on_DetectionArea_body_entered(body):
	current_state.handle_event("body_entered", body)


func _on_DetectionArea_body_exited(body):
	current_state.handle_event("body_exited", body)


func _on_Body_animation_finished():
	_on_animation_finished(character.get_current_animation())


func _on_Sprout_hit(amount) -> void:
	if current_state != $Die:
		_change_state("die")


func notify_hit(amount):
	current_state.handle_event("hit", amount)


func _on_AreaDamage_body_entered(body):
	pass # Replace with function body.
