extends Node
class_name Game_State


## Señal y variable de ayuda que permite notificar la existencia
## del jugador actual a cualquiera interesado
signal current_player_changed(player)

var current_player: Player

func set_current_player(player: Player) -> void:
	current_player = player
	emit_signal("current_player_changed", player)


## Señal genérica que avisa del cumplimiento de la condición
## de victoria a todos los interesados.
signal level_won()

func notify_level_won() -> void:
	emit_signal("level_won")


signal input_map_changed()

func notify_input_map_changed() -> void:
	emit_signal("input_map_changed")
