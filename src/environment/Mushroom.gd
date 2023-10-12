extends Node2D
class_name Mushroom


func _on_Area2D_body_entered(body):
	if body is Player:
		body.ACCELERATION*3
		print(body.ACCELERATION)
		queue_free()
