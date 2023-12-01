extends Area2D

onready var animation_player = $AnimationPlayer

var won: bool = false


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(_body: Node) -> void:
	if !won && GameState.deaths >= 10:
		won = true
		GameState.game_finished = true
		GameState.checkpoint_actived = false
		GameState.changed_audio_final_activate = false
		GameState.spawn_point = null
		GameState.chance = 3
		GameState.notify_level_won()
	else:
		animation_player.play("globe")

