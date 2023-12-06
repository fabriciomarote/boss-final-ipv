extends KinematicBody2D
class_name Cannon

onready var fire_position: Position2D = $Pivot/FirePosition
onready var pivot:Node2D = $Pivot
onready var timer = $StateMachine/Alert/Timer

export (PackedScene) var projectile_scene: PackedScene


var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO


func _ready():
	initialize()

func initialize(_projectile_container: Node = get_parent()) -> void:
	self.projectile_container = _projectile_container


func _fire() -> void:
	if (GameState.cannon1_active):
		var direction: Vector2 = Vector2(round(global_position.direction_to(fire_position.global_position).x), 0)
		var proj = projectile_scene.instance()
		proj.initialize(
			self.projectile_container,
			fire_position.global_position,
			direction
		)


func _look_at_target() -> void:
	if target != null:
		pivot.scale.x = -1 if target.global_position.x > global_position.x else 1
	else:
		pivot.scale.x = -1 if velocity.x > 0 else 1


func _on_Timer_timeout():
	timer.wait_time = randi() % 4 + 1
