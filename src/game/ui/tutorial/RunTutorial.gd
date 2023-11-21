extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var keyboard = $Elements/RunAction/Keyboard

export (String) var action: String

var enabled: bool = false

func ready() -> void:
	GameState.connect("input_map_changed", self, "_refresh_inputs")


func _on_PlayerCloseArea_body_entered(body):
	if !enabled:
		enabled = true
		if InputMap.has_action(action):
			var text = InputMap.get_action_list(action)[0]
			keyboard.text = text.as_text()
		animation_player.play("enabled")
