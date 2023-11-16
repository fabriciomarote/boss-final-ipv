extends Area2D


var won: bool = false


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(_body: Node) -> void:
	if !won:
		won = true
		GameState.game_finished = true
		GameState.checkpoint_actived = false
		GameState.spawn_point = null
		GameState.notify_level_won()

