extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var label = $Elements/VBoxContainer/Label2/Label
onready var label_2 = $Elements/VBoxContainer2/Label2/Label2

var enabled: bool = false

export (String) var action1: String
export (String) var action2: String

func ready() -> void:
	GameState.connect("input_map_changed", self, "_refresh_inputs")
	#_refresh_inputs()


func _on_PlayerCloseArea_body_entered(body):
	if !enabled:
		enabled = true
		animation_player.play("enabled")
