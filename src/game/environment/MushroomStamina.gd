extends Node2D
class_name MushroomStamina

func _on_Area2D_body_entered(body):
	if body is Player:
		body.sum_stamina()
		queue_free()
