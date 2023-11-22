extends Node

onready var start_animation: AnimationPlayer = $StartAnimation
onready var ui_sfx: AudioStreamPlayer = $UiSfx

var button : AudioStream = preload("res://assets/sounds/ui/Minimalist4.wav")

export (Texture) var mouse_cursor: Texture

func _ready() -> void:
	Input.set_custom_mouse_cursor(mouse_cursor)


func _on_StartButton_pressed():
	ui_sfx.play()
	start_animation.play("start")


func _on_ExitButton_pressed():
	ui_sfx.play()
	get_tree().quit()


func _transition_start() -> void:
	get_tree().change_scene("res://src/game/levels/MenuContext.tscn")
