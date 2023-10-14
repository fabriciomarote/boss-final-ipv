extends AbstractState

onready var fx_anim: AnimationPlayer = $"../../WeaponContainer/Weapon/FXAnim"
var fire_tween: SceneTreeTween

# Al entrar se activa primero la animación "arrow"
func enter() -> void:
	character._play_animation("arrow")
	fire()

func fire() -> void:
	if !fx_anim.is_playing(): #and contiene flecha:
		## Mato al tween antes de disparar para que no me cambie la rotación
		if fire_tween != null:
			fire_tween.kill()
		
		## No disparo de inmediato, sino que delego a una animación de disparo
		fx_anim.play("fire")

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name:String) -> void:
	#if (anim_name == "arrow"):
		#character._handle_weapon_actions()
	emit_signal("finished", "idle")
