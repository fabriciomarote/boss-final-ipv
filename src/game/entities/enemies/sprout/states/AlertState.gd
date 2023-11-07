extends AbstractEnemyState

onready var timer:Timer = $Timer
var attack_distance_threshold:int = 100

func enter() -> void:
	character.velocity = Vector2.ZERO
	character._play_animation("alert")
	attack()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()


func update(delta) -> void:
	character._look_at_target()


func exit() -> void:
	timer.stop()


func attack() -> void:
	#character._fire()
	character._play_animation("attack")


func should_attack() -> bool:
	var abs_position_diff: int
	if character.target != null:
		abs_position_diff = abs(character.target.global_position.x - character.global_position.x)
	return abs_position_diff <= attack_distance_threshold


## Usamos la duración de las animaciones como "trigger" para iniciar otras
## acciones. Quizás no sea lo óptimo, pero genera una sensación de "progresión".
## Se podría meter un Timer para manejarlo de otra manera también
func _on_animation_finished(anim_name: String) -> void:
	if character.target == null:
		emit_signal("finished", "idle")
	else:
		match anim_name:
			## Si terminó la animación de ataque, entramos en "alert" que
			## permite meter un "cooldown" al ataque en si
			"attack":
				character._play_animation("alert")
			## Si terminó la animación de "cooldown", determinamos si
			## podemos seguir disparando o regresamos a Idle
			"alert":
				if character._can_see_target():
					attack()
				else:
					emit_signal("finished", "idle")


func _on_timer_timeout() -> void:
	if !should_attack():
		timer.stop()
		emit_signal("finished", "walk")
	else:
		attack()


func handle_event(event: String, value = null) -> void:
	.handle_event(event,value)
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")

