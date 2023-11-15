## Esta State Machine en particular del player solo extiende la
## funcionalidad de la State Machine abstracta para ajustarse
## a las necesidades del personaje a usar. Para estructuras de juego
## más complejas, generalmente se abstraen estos métodos para crear
## un controller genérico que se pueda asignar a cualquier entidad.
extends AbstractStateMachine


## Esta función deriva el handleo de cada golpe que recibe
## el personaje al estado actual particular, en vez de vincular
## la señal de "hit" a los estados que lo usan, ya que sino se
## podría ejecutar código de estados inactivos.
func notify_hit(amount: int) -> void:
	current_state.handle_event("hit", amount)


func _on_Player_protection_changed(protection, max_protection):
	current_state.handle_event("protection_changed", [protection, max_protection])


