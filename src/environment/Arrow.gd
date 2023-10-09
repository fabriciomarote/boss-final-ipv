extends Node2D
class_name Arrow

func _on_body_entered(body):
	if body is Player:
		print(body.arrowAmount)
		body.handle_arrow()
		queue_free()
