extends AbstractEnemyState
onready var timer:Timer = $Timer
var attack_distance_threshold:int = 100

func enter() -> void:
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.start()


func _do_fire() -> void:
	character._fire()
	timer.start()


func _on_Timer_timeout():
	var shoot = true
	if shoot:
		print("dispara")
		_do_fire()
