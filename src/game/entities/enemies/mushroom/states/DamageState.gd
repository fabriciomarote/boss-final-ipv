extends AbstractState


func enter() -> void:
	character.emit_signal("damage")
	character._play_animation("damage")


func _on_animation_finished(anim_name:String) -> void:
	if (anim_name == "damage"):
		emit_signal("finished", "idle")
	if character.dead:
		emit_signal("finished", "die")
