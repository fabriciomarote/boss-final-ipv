extends Node
class_name Game_State

var checkpoint_actived: bool = false
var spawn_point = null


signal current_player_changed(player)

var chance: int = 3

var current_player: Player

func set_current_player(player: Player) -> void:
	current_player = player
	if checkpoint_actived:
		current_player.global_position = spawn_point
	emit_signal("current_player_changed", player)


signal level_won()

func notify_level_won() -> void:
	emit_signal("level_won")


signal input_map_changed()

func notify_input_map_changed() -> void:
	emit_signal("input_map_changed")
