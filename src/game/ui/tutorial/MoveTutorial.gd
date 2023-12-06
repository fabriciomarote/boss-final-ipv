extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var keyboard = $"%Keyboard1"
onready var keyboard_1 = $"%Keyboard"

export (String) var action1: String
export (String) var action2: String

var enabled: bool = false


func _on_PlayerCloseArea_body_entered(_body):
	if !enabled:
		enabled = true
		if InputMap.has_action(action1):
			var text = InputMap.get_action_list(action1)[0]
			keyboard_1.text = text.as_text()
		if InputMap.has_action(action2):
			var text = InputMap.get_action_list(action2)[0]
			keyboard.text = text.as_text()
		animation_player.play("enabled")
