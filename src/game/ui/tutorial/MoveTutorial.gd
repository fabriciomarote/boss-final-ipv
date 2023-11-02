extends Node2D

onready var enabling_animation: AnimationPlayer = $EnablingAnimation

var enabled: bool = false


func _ready() -> void:
	GameState.connect("input_map_changed", self, "_refresh_inputs")
	_refresh_inputs()


func _refresh_inputs() -> void:
	pass


func _on_PlayerCloseArea_body_entered(body: Node) -> void:
	if !enabled:
		enabled = true
		enabling_animation.play("enabled")
