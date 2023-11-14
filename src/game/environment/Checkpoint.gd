extends Area2D

func _on_Checkpoint_body_entered(body):
	if body is Player: 
		GameState.spawn_point = body.global_position
		$CollisionShape2D.set_deferred("disabled", true)
