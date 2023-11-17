extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer

var enabled: bool = false

func ready() -> void:
	GameState.connect("input_map_changed", self, "_refresh_inputs")
	#_refresh_inputs()


func _on_PlayerCloseArea_body_entered(body):
	if !enabled:
		enabled = true
		animation_player.play("enabled")
