extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var keyboard = $Elements/VBoxContainer/Label2/Keyboard
onready var keyboard_1 = $Elements/VBoxContainer2/Label2/Keyboard1

var enabled: bool = false

export (String) var action1: String
export (String) var action2: String


func _on_PlayerCloseArea_body_entered(_body):
	if !enabled:
		enabled = true
		if InputMap.has_action(action1):
			var text = InputMap.get_action_list(action1)[0]
			keyboard.text = text.as_text()
		if InputMap.has_action(action2):
			var text = InputMap.get_action_list(action2)[0]
			keyboard_1.text = text.as_text()
		animation_player.play("enabled")
