extends AbstractEnemyState


func enter() -> void:
	character._play_animation("attack")
	character.attack()

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			emit_signal("finished", "damage")
			if character.dead:
				emit_signal("finished", "die")


func _on_animation_finished(anim_name:String) -> void:
	if (character.hp == 0):
		emit_signal("finished", "die")
	if (anim_name == "attack"):
		emit_signal("finished", "idle")

