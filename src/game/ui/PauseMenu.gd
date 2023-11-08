extends Control

onready var options_menu: Control = $OptionsMenu
onready var pause_sfx: AudioStreamPlayer = $PauseSfx

var button : AudioStream = preload("res://assets/sounds/ui/Minimalist4.wav")


signal return_selected()
signal restart_selected()

#export (AudioStream) var button_sfx

func _ready():
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause_menu") && !options_menu.visible:
		visible = !visible
		get_tree().paused = visible


func _on_ResumeButton_pressed():
	pause_sfx.stream = button
	pause_sfx.play()
	hide()
	get_tree().paused = false


func _on_ReturnButton_pressed():
	pause_sfx.stream = button
	pause_sfx.play()
	emit_signal("return_selected")


func _on_RestartButton_pressed():
	pause_sfx.stream = button
	pause_sfx.play()
	hide()
	emit_signal("restart_selected")


func _input(event: InputEvent) -> void:
	if event.is_action("reset"):
		get_tree().reload_current_scene()

