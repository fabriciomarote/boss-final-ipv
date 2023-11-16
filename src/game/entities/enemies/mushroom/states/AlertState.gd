extends AbstractEnemyState
onready var timer:Timer = $Timer
var attack_distance_threshold:int = 200

func enter() -> void:
	character.velocity = Vector2.ZERO
	character._play_animation("alert")
	_attack()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()
	
func update(delta:float) -> void:
	character._look_at_target()
	
func exit() -> void:
	timer.stop()
		
func _should_fire() -> bool:
	var abs_position_diff: int
	if character.target != null:
		abs_position_diff = abs(character.target.global_position.x - character.global_position.x)
	return abs_position_diff <= attack_distance_threshold

func _attack() -> void:
	#character._play_animation("attack")
	character._fire()
	timer.start()
		
func _on_timer_timeout() -> void:
	if !_should_fire():
		timer.stop()
		emit_signal("finished", "walk")
	else:
		_attack()

func _handle_body_exited(node: Node) -> void:
	._handle_body_exited(node)
	if character.target == null:
		if character.get_current_animation() == "alert":
			emit_signal("finished", "walk")

func handle_event(event: String, value = null) -> void:
	.handle_event(event,value)
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")
