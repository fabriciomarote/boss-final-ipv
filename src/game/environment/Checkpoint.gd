extends Area2D

func _on_Checkpoint_body_entered(body):
	if body is Player: 
		print(global_position)
		GameState.spawn_point = body.global_position
		GameState.checkpoint_actived = true
		print(GameState.spawn_point)
		$CollisionShape2D.set_deferred("disabled", true)
