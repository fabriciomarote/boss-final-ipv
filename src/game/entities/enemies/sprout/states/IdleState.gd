## Este estado hereda de un State intermedio llamado AbstractEnemyState
## que extiende la interfaz de State con comportamientos específicos
## (se puede abrir el script con Ctrl+click)
extends AbstractEnemyState

# Usamos un Timer para controlar cuánto tiempo queda in Idle
onready var timer:Timer = $Timer


func enter() -> void:
	# Seteamos la velocidad a (0,0) para que no se mueva
	character.velocity = Vector2.ZERO
	
	# Chequeamos si debe estar con la guardia en alto o no
	if character.target != null:
		character._play_animation("idle_alert")
	else:
		character._play_animation("idle")
	# Iniciamos el Timer para salir del estado
	timer.start()


func update(delta:float) -> void:
	# Primero detenemos el character para que no se mueva más
	character._handle_deacceleration(delta)
	# Aplicamos el movimiento en el personaje
	character._apply_movement()
	
	# Y si notamos que puede "ver" al objetivo, entramos en Alert
	if character._can_see_target():
		emit_signal("finished", "alert")


# Al salir, nos aseguramos de limpiar el timer de Idle
func exit() -> void:
	timer.stop()


func _handle_body_entered(body: Node) -> void:
	._handle_body_entered(body)
	
	## No se ejecuta directamente el "idle_alert", sino que se ejecuta una
	## animación de transición
	character._play_animation("alert")


func _handle_body_exited(body) -> void:
	._handle_body_exited(body)
	
	## No se ejecuta directamente el "idle", sino que se ejecuta una
	## animación de transición
	character._play_animation("go_normal")


# Manejamos la transicion de animaciones "intermedias" a animaciones finales
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"alert":
			character._play_animation("idle_alert")
		"go_normal":
			character._play_animation("idle")


func _on_Timer_timeout():
	emit_signal("finished", "walk")


func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "die")
