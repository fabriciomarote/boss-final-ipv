extends Control

## Menú de victoria genérico. Solo se presenta si se levanta la signal
## de "level_won" en GameState.

signal restart_selected()
signal return_selected()

onready var sfx = $SFX

var button : AudioStream = preload("res://assets/sounds/PosiblesAudios/GameMenu4.wav")

func _ready() -> void:
	hide()
	GameState.connect("level_won", self, "_on_level_won")


func _on_level_won() -> void:
	show()


func _on_ReturnButton_pressed() -> void:
	GameState.deaths = 0
	GameState.chance = 3
	GameState.changed_audio_final_activate = false
	GameState.checkpoint_actived = false
	sfx.stream = button
	sfx.play()
	emit_signal("return_selected")


func _on_restart_requested():
	GameState.deaths = 0
	GameState.chance = 3
	GameState.changed_audio_final_activate = false
	GameState.checkpoint_actived = false
	sfx.stream = button
	sfx.play()
	hide()
	emit_signal("restart_selected")
