extends Node
class_name Game_State

var checkpoint_actived: bool = false
var spawn_point = null
var position_original : Vector2
var game_finished: bool = false
var final_audio: bool = false
var intermedio_audio: bool = false

signal current_player_changed(player)

var chance: int = 3

var current_player: Player

func set_current_player(player: Player) -> void:
	current_player = player
	#position_original = current_player.global_position
	if checkpoint_actived && !game_finished:
		current_player.global_position = spawn_point
	emit_signal("current_player_changed", player)
	

func set_level():
	if final_audio:
		return preload("res://assets/sounds/level/audio_final2.mp3")
	if intermedio_audio:
		return preload("res://assets/sounds/level/audio_intermedio2.mp3")

signal level_won()

func notify_level_won() -> void:
	emit_signal("level_won")


signal input_map_changed()

func notify_input_map_changed() -> void:
	emit_signal("input_map_changed")
