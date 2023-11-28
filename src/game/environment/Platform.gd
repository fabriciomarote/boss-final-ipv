extends StaticBody2D


func _on_Area2D_body_entered(body):
	if body is Player:
		if body.has_method("notify_hit") && !body.protection_actived:
			body.notify_hit(1)
		if body.has_method("notify_hit_protection") && body.protection_actived:
			body.notify_hit_protection()
