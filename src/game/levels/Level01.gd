extends Node
class_name GameLevel

onready var passage_area: Area2D = $Environment/PassageArea

var enabled: bool = false

# Regresa al menu principal
signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()

func _ready() -> void:
	randomize()


# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	emit_signal("next_level_requested")


func _on_return_requested() -> void:
	emit_signal("return_requested")


func _on_restart_requested() -> void:
	emit_signal("restart_requested")


func _on_DesactivationArea_body_entered(body):
	if !enabled:
		enabled = true
		passage_area.visible = false
