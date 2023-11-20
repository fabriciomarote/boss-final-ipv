extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var label: Label = $"%Label"
onready var label_2: Label = $"%Label2"

export (String) var action1: String
export (String) var action2: String

var enabled: bool = false

func ready() -> void:
	GameState.connect("input_map_changed", self, "_refresh_inputs")


func _on_PlayerCloseArea_body_entered(body):
	if !enabled:
		enabled = true
		if InputMap.has_action(action1):
			var text = InputMap.get_action_list(action1)[0]
			label.text = text.as_text()
		if InputMap.has_action(action2):
			var text = InputMap.get_action_list(action2)[0]
			label_2.text = text.as_text()
		animation_player.play("enabled")
