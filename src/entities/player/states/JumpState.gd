extends AbstractState

export (int) var jumps_limit: int = 1

var jumps = 0

func enter() -> void:
	character.snap_vector = Vector2.ZERO
	do_jump()
	
func exit() -> void:
	jumps = 0
	
func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("jump") && jumps < jumps_limit:
		jumps += 1
		do_jump()

func do_jump() -> void: 
	character.velocity.y -= character.jump_speed
	character._play_animation("jump")

func update(delta: float) -> void:
	character._handle_weapon_actions()
	character._handle_move_input()
	if character.move_direction == 0:
		character._handle_deacceleration()
	character._apply_movement()
	if character.is_on_floor():
		if character.move_direction == 0: 
			emit_signal("finished", "idle")
		else: 
			emit_signal("finished", "walk")

# En este callback manejamos, por el momento, solo los impactos
func handle_event(event: String, value = null) -> void:
	match event:
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")
  
