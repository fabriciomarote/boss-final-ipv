extends Control

onready var options_menu: Control = $OptionsMenu
onready var pause_sfx: AudioStreamPlayer = $PauseSfx

var button : AudioStream = preload("res://assets/sounds/PosiblesAudios/GameMenu4.wav")


signal return_selected()
signal restart_selected()


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
	GameState.game_finished = true
	GameState.checkpoint_actived = false
	GameState.spawn_point = null
	GameState.deaths = 0
	emit_signal("return_selected")


func _on_RestartButton_pressed():
	pause_sfx.stream = button
	pause_sfx.play()
	GameState.game_finished = true
	GameState.checkpoint_actived = false
	GameState.spawn_point = null
	hide()
	GameState.deaths = 0
	emit_signal("restart_selected")


func _input(event: InputEvent) -> void:
	if event.is_action("reset"):
		#GameState.game_finished = true
		#GameState.checkpoint_actived = false
		#GameState.spawn_point = null
		get_tree().reload_current_scene()

func _on_restart_requested():
	hide()
	emit_signal("restart_selected")
