extends StaticBody2D

onready var raycast: RayCast2D = $RayCast2D
onready var body_anim = $Body

export (PackedScene) var projectile_scene: PackedScene

var target: Node2D
var projectile_container: Node

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func _ready() -> void:
	set_physics_process(false)
	_play_animation("idle")


func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container

func _physics_process(delta: float) -> void:
	pass


## Esta función ya no llama directamente a remove, sino que inhabilita las
## colisiones con el mundo, pausa todo lo demás y ejecuta una animación de muerte
func notify_hit() -> void:
	print("I'm turret and imma die")
	dead = true
	_play_animation("death")
	body_anim.connect("animation_finished",self, "_on_animation_finished")


func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()


func _on_DetectionArea_body_entered(body: Node) -> void:
	if target == null:
		target = body
		set_physics_process(true)


func _on_DetectionArea_body_exited(body: Node) -> void:
	if body == target:
		target = null
		set_physics_process(false)


## Acá manejamos el callback de "animation finished" y procesamos qué
## lógica ejecutar a continuación, estilo grafo.
func _on_animation_finished() -> void:
	_remove()


## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_anim.frames.has_animation(animation):
		body_anim.play(animation)
