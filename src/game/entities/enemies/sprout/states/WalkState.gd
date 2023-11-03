extends AbstractEnemyState

export (float) var speed:float
export (float) var max_speed:float

var attack_distance_threshold:int = 100

var path: Array = []


func enter() -> void:
	character._play_animation("walk")


func exited() -> void:
	path = []


func update(delta:float) -> void:
	
	if character.target && abs(character.target.global_position.x - character.global_position.x) <= attack_distance_threshold:
		emit_signal("finished", "alert")
	
	if character.navigation_agent != null:
		var direction:Vector2 = character.global_position.direction_to(
			character.navigation_agent.get_next_location()
		)
		var desired_velocity = direction * character.H_SPEED_LIMIT
		var steering = (desired_velocity - character.velocity) * delta * character.ACCELERATION
		character.velocity += steering 
	character._apply_movement()
