extends Area2D


func _on_AreaDeath_body_entered(body):
	if body is Player:
		body.notify_dead()
