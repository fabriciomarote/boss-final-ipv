extends AbstractEnemyState

export (float) var speed:float
export (float) var max_speed:float

var attack_distance_threshold:int = 100

var path: Array = []


func enter() -> void:
	print(character)
	character._play_animation("fly")


func exited() -> void:
	path = []
	
func update(delta:float) -> void:
	
	if character.navigation_agent != null:
		var direction:Vector2 = character.global_position.direction_to(
			character.navigation_agent.get_next_location()
		)
		var desired_velocity = direction * character.H_SPEED_LIMIT
		var steering = (desired_velocity - character.velocity) * delta * character.ACCELERATION
		character.velocity += steering 
	character.apply_movement()
