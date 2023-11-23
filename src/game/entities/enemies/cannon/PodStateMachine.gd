extends AbstractStateMachine

class_name PodStateMachine

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func _on_DetectionArea_body_entered(body):
	current_state.handle_event("body_entered", body)

func _on_DetectionArea_body_exited(body):
	current_state.handle_event("body_exited", body)
