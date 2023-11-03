extends AbstractEnemyState

func enter() -> void:
	character._play_animation("death")
	character.dead = true
	character.collision_layer = 0
	character.collision_mask = 0
	
	if character.target == null:
		character._play_animation("death")
	
func _on_animation_finished(anim_name: String) ->  void:
	if anim_name in ["death"]:
		character._remove()