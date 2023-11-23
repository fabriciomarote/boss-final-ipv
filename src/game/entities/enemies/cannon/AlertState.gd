extends AbstractEnemyState

onready var timer:Timer = $Timer

func enter() -> void:
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start()


func _fire() -> void:
	character._fire()
	timer.start()


func _on_Timer_timeout():
	var shoot = true
	if shoot:
		_fire()
