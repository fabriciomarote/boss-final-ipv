extends KinematicBody2D
class_name CannonWater

onready var fire_position: Position2D = $Pivot/FirePosition
onready var body_anim: AnimatedSprite = $Pivot/Body
onready var pivot:Node2D = $Pivot


export (PackedScene) var projectile_scene: PackedScene


var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO


func _ready():
	initialize()

func initialize(_projectile_container: Node = get_parent()) -> void:
	self.projectile_container = _projectile_container


func _fire() -> void:
	var direction: Vector2 = Vector2(0, round(global_position.direction_to(fire_position.global_position).y))
	var proj = projectile_scene.instance()
	proj.initialize(
		self.projectile_container,
		fire_position.global_position,
		direction
	)
	
func _look_at_target() -> void:
	if target != null:
		pivot.scale.y = -1 if target.global_position.y > global_position.y else 1
	else:
		pivot.scale.y = -1 if velocity.y > 0 else 1
