extends AbstractEnemyState
onready var timer:Timer = $Timer
var attack_distance_threshold:int = 100

func enter() -> void:
	character.velocity = Vector2.ZERO
	character._play_animation("alert")
	_do_fire()
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

func _do_fire() -> void:
	character._fire()
	timer.start()
		
func _on_timer_timeout() -> void:
	if !_should_fire():
		timer.stop()
		emit_signal("finished", "walk")
	else:
		_do_fire()
