extends AbstractState


func enter() -> void:
	character._play_animation("damage")
	character._damage_audio()


func _on_animation_finished(anim_name:String) -> void:
	if (anim_name == "damage"):
		emit_signal("finished", "idle")
	if character.dead:
		emit_signal("finished", "die")
