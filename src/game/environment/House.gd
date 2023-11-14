extends Area2D


var won: bool = false


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(_body: Node) -> void:
	if !won:
		won = true
		GameState.notify_level_won()

