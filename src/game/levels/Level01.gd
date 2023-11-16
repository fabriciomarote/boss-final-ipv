extends Node
class_name GameLevel

onready var passage: StaticBody2D  = $Environment/Passage
onready var passage_area: Area2D = $Environment/Passage/PassageArea
onready var collision_shape = $Environment/Passage/CollisionShape2D
onready var collision_shape_area = $Environment/Passage/PassageArea/CollisionShape2D
onready var animation_player = $AnimationPlayer
onready var bgm: AudioStreamPlayer = $BGM
onready var player: Player = $Environment/Entities/Player

var enabled: bool = false

# Regresa al menu principal
signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()
signal continue_level()
signal player_dead

func _ready() -> void:
	randomize()

# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	emit_signal("next_level_requested")


func _on_return_requested() -> void:
	emit_signal("return_requested")


func _on_restart_requested() -> void:
	emit_signal("restart_requested")


func _on_continue_level() -> void:
	emit_signal("continue_level")

func _on_DesactivationArea_body_entered(_body):
	if !enabled:
		enabled = true
		print("desbloqueo")
		animation_player.play("passage")


func _on_ChangeAudioArea_body_entered(_body):
	 bgm.stream = preload("res://assets/sounds/audio_final.ogg")
	 bgm.play()
