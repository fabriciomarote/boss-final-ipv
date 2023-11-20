extends Node

onready var ui_sfx = $UiSfx
onready var animation_player = $AnimationPlayer
onready var bgm = $BGM

export (PackedScene) var level_manager_scene: PackedScene


func _ready():
	set_process(false)


func _unhandled_input(_event):
	if Input.is_action_pressed("start"):
		animation_player.play("start")


func _transition_start() -> void:
	get_tree().change_scene_to(level_manager_scene)
