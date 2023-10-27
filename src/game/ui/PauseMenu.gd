extends Control

onready var options_menu: Control = $OptionsMenu

signal return_selected()

func _ready():
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause_menu") && !options_menu.visible:
		visible = !visible
		get_tree().paused = visible


func _on_ResumeButton_pressed():
	hide()
	get_tree().paused = false

func _on_ReturnButton_pressed():
	emit_signal("return_selected")
