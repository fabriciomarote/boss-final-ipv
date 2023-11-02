extends Node2D
class_name Arrow

func _on_Area2D_body_entered(body):
	if body is Player:
		body.handle_arrow()
		queue_free()
