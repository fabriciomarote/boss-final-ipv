extends Node
class_name Game_State

var checkpoint_actived: bool = false
var changed_audio_final_activate: bool = false
var spawn_point = null
var position_original : Vector2
var game_finished: bool = false
var deaths: int = 0

signal current_player_changed(player)
signal current_chance_changed(chance)
signal dead_change(amount)

var chance: int = 3

var current_player: Player

func set_current_player(player: Player) -> void:
	current_player = player
	if checkpoint_actived && !game_finished:
		print(checkpoint_actived)
		print(!game_finished)
		current_player.global_position = spawn_point
	current_player.deaths = deaths
	emit_signal("current_player_changed", player)


func set_current_chance() -> void:
	emit_signal("current_chance_changed", chance)


func set_level():
	if checkpoint_actived:
		return preload("res://assets/sounds/level/audio_intermedio2.mp3")
	if checkpoint_actived && changed_audio_final_activate:
		return preload("res://assets/sounds/level/audio_final2.mp3") 
	else:
		return preload("res://assets/sounds/level/audio_tutorial2.ogg")


signal level_won()

func notify_level_won() -> void:
	emit_signal("level_won")


signal enemy_dead()

func notify_dead() -> void:
	emit_signal("enemy_dead")
	deaths += 1
	emit_signal("dead_change", deaths)

signal chance_subtract()

func chances_subtract() -> void:
	emit_signal("chance_subtract")
	chance -= 1


signal input_map_changed()

func notify_input_map_changed() -> void:
	emit_signal("input_map_changed")
