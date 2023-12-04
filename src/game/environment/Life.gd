extends Node2D
class_name Life

onready var sfx = $SFX

export (AudioStream) var handle_sfx

func _on_Area2D_body_entered(body):
	if body is Player:
		if body.hp < body.max_hp:
			_handle_audio()
			body.sum_hp()
			queue_free()


func _handle_audio():
	sfx.stream = handle_sfx
	sfx.play() 
