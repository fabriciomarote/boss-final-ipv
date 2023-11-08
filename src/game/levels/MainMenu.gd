extends Node

onready var start_animation: AnimationPlayer = $StartAnimation
onready var ui_sfx: AudioStreamPlayer = $UiSfx

var button : AudioStream = preload("res://assets/sounds/ui/Minimalist4.wav")

export (PackedScene) var level_manager_scene: PackedScene

export (Texture) var mouse_cursor: Texture


func _ready() -> void:
	Input.set_custom_mouse_cursor(mouse_cursor)


func _on_StartButton_pressed():
	start_animation.play("start")


func _on_ExitButton_pressed():
	ui_sfx.stream = button
	ui_sfx.play()
	get_tree().quit()


func _transition_start() -> void:
	get_tree().change_scene_to(level_manager_scene)
