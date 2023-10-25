extends Node
class_name GameLevel

# Regresa al menu principal
signal return_requested()
# Reinicia el nivel
signal restart_requested()


func _ready() -> void:
	randomize()


# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	emit_signal("next_level_requested")


func _on_return_requested() -> void:
	emit_signal("return_requested")


func _on_restart_requested() -> void:
	emit_signal("restart_requested")


## Agregamos un botoncito primitivo de reset. Por default es la "R".
func _input(event: InputEvent) -> void:
	if event.is_action("reset"):
		get_tree().reload_current_scene()
