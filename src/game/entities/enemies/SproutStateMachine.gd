extends AbstractStateMachine
class_name SproutStateMachine

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
	#current_state.handle_event("hit", amount)
	if current_state != $Die:
		_change_state("die")


func _on_Sprout_hp_changed(current_hp, max_hp):
	pass
	#current_state.handle_event("hp_changed", [hp, max_hp])