extends AbstractEnemyState

export (Vector2) var wander_radius
export (float) var speed:float
export (float) var max_speed:float
export (float) var pathfinding_step_threshold:float = 5.0

var path: Array = []


func enter() -> void:
	if character.pathfinding !=null:
		var random_target: Vector2 = (
			character.global_position + 
			Vector2(
				rand_range(wander_radius.x, wander_radius.x),
				rand_range(wander_radius.y, wander_radius.y)
			)
		)
		path = character.pathfinding.get_simple_path(character.global_position, random_target)
		if path.empty() || path.size() == 1:
			emit_signal("finished", "idle")
		else:
			if character.target != null:
				character._play_animation("fly_alert")	
			else:
				character._play_animation("fly")	
	else:
		emit_signal("finished", "idle")


func exited() -> void:
	path = []
	
func update(delta:float) -> void:
	if character._can_see_target():
		emit_signal("finished", "alert")
		return
	
	if path.empty():
		emit_signal("finished", "idle")
		return
		
	var next_point:Vector2 = path.front()
	while character.global_position.distance_to(next_point) < pathfinding_step_threshold:
		path.pop_front()
		if path.empty():
			emit_signal("finished", "idle")
			return
		next_point= path.front()
	
	character.velocity = (
		character.velocity +
		character.global_position.direction_to(next_point) * speed
	).clamped(max_speed)
	character._apply_movement()
	character.body_anim.flip_h = character.velocity.x < 0
	
func _handle_body_entered(body: Node) -> void:
	._handle_body_entered(body)
	character._play_animation("alert")
	
func _handle_body_exited(body: Node) -> void:
	._handle_body_exited(body)
	character._play_animation("go_normal")
	
func _on_amimation_finished(anim_name: String) -> void:
	match anim_name:
		"alert":
			character._play_animation("fly_alert")
		"go_normal":
			character._play_animation("fly")


func handle_event(event: String, value = null) -> void:
	.handle_event(event,value)
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")
