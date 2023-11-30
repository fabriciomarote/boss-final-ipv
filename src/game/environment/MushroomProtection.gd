extends Node2D
class_name MushroomProtection


func _on_Area2D_body_entered(body):
	if body is Player:
		if body.protection < body.max_protection:
			body.sum_protection()
			queue_free()
