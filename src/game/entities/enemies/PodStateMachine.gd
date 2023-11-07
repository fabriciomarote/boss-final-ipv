extends AbstractStateMachine
class_name PodStateMachine


func _on_DetectionArea_body_entered(body):
	current_state.handle_event("body_entered", body)

func _on_DetectionArea_body_exited(body):
	current_state.handle_event("body_exited", body)


func notify_hit(amount):
	current_state.handle_event("hit", amount)


func _on_Body_animation_finished():
	_on_animation_finished(character.get_current_animation())


func _on_Sprout_hp_changed(hp, max_hp):
	current_state.handle_event("hp_changed", [hp, max_hp])
