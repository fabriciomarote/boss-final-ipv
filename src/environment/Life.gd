extends Node2D
class_name Life

func _on_Area2D_body_entered(body):
	if body is Player:
		if body.hp < 3:
			body.sum_hp(1)
			queue_free()
