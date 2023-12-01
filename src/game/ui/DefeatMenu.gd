extends Control

## Menú de derrota genérico. Solo se presenta si detecta que
## el Player llegó a 0 de HP.

signal retry_selected()
signal return_selected()

func _ready() -> void:
	hide()
	if GameState.chance == 0:
		show()


func _on_RetryButton_pressed() -> void:
	hide()
	GameState.chance = 3
	GameState.deaths = 0
	GameState.game_finished = true
	GameState.checkpoint_actived = false
	GameState.changed_audio_final_activate = false
	GameState.spawn_point = null
	emit_signal("retry_selected")


func _on_ReturnButton_pressed() -> void:
	hide()
	GameState.game_finished = true
	GameState.checkpoint_actived = false
	GameState.changed_audio_final_activate = false
	GameState.spawn_point = null
	GameState.chance = 3
	GameState.deaths = 0
	emit_signal("return_selected")
