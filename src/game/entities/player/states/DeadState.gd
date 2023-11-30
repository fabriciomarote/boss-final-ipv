extends AbstractState


## Al ser un estado de finalización (es decir, no se sale
## a ningun otro estado), vamos a procesar todo lo necesario
## en el enter
func enter() -> void:
	character._play_animation("death")


## Y en update solo manejamos la fricción y movimiento
## para que no sea un cubo de hielo al morir
func update(_delta) -> void:
	character._handle_deacceleration()
	character._apply_movement()


## Para este punto solo hay una animación reproduciendose
## por lo que podemos extraer el llamado a _remove desde la
## animación a esta función
func _on_animation_finished(_anim_name:String) -> void:
	character._remove()
