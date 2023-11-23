extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var keyboard_1 = $Elements/JumpAction1/ActionLabel/Keyboard1
onready var keyboard_2 = $Elements/JumpAction2/ActionLabel/keyboard2
onready var keyboard = $Elements/JumpAction2/ActionLabel/Keyboard

export (String) var action: String

var enabled: bool = false

func ready() -> void:
	GameState.connect("input_map_changed", self, "_refresh_inputs")


func _on_PlayerCloseArea_body_entered(_body):
	if !enabled:
		enabled = true
		if InputMap.has_action(action):
			var text = InputMap.get_action_list(action)[0]
			keyboard.text = text.as_text()
		if InputMap.has_action(action):
			var text = InputMap.get_action_list(action)[0]
			keyboard_1.text = text.as_text()
		if InputMap.has_action(action):
			var text = InputMap.get_action_list(action)[0]
			keyboard_2.text = text.as_text()
		animation_player.play("enabled")
