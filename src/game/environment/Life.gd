extends Node2D
class_name Life


func _on_Area2D_body_entered(body):
	if body is Player:
		if body.hp < body.max_hp:
			queue_free()
		body.sum_hp()
