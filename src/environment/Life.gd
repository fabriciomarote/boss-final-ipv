extends Node2D
class_name Life

func _on_Area2D_body_entered(body):
	if body is Player:
		if body.lifeAmount < 3:
			body.handle_Life()
			queue_free()
