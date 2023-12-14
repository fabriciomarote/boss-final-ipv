extends AbstractEnemyState

export (float) var speed:float
export (float) var max_speed:float

var attack_distance_threshold:int = 50

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


func _handle_body_exited(node: Node) -> void:
	._handle_body_exited(node)
	if character.target == null:
		if character.get_current_animation() == "walk":
			emit_signal("finished", "idle")


func handle_event(event: String, value = null) -> void:
	.handle_event(event,value)
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")
