extends Node
class_name GameLevel

onready var passage: StaticBody2D  = $Environment/Passage
onready var passage_area: Area2D = $Environment/Passage/PassageArea
onready var collision_shape = $Environment/Passage/CollisionShape2D
onready var collision_shape2 = $Environment/ChangeAudioArea2/CollisionShape2D

onready var collision_shape_area = $Environment/Passage/PassageArea/CollisionShape2D
onready var animation_player = $AnimationPlayer
onready var bgm: AudioStreamPlayer = $BGM/BGM
onready var player: Player = $Environment/Entities/Player

var enabled: bool = false

# Regresa al menu principal
signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()
signal continue_level()

func _ready() -> void:
	randomize()
	animation_player.play("start")
	bgm.stream = GameState.set_level_audio()
	bgm.play()


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
		animation_player.play("passage")


func _on_ChangeAudioArea_body_entered(body):
	if body is Player:
		 bgm.stream = preload("res://assets/sounds/level/audio_intermedio2.mp3")
		 bgm.play()


func _on_ChangeAudioArea2_body_entered(body):
	if body is Player:
		 GameState.changed_audio_final_activate = true
		 collision_shape2.disabled = true
		 bgm.stream = preload("res://assets/sounds/level/audio_final2.mp3")
		 bgm.play()


func _on_AreaAudioCannon_body_entered(_body):
	GameState.cannon2_active = !GameState.cannon2_active


func _on_AreaAudioCannon_body_exited(_body):
	GameState.cannon2_active = !GameState.cannon2_active


func _on_AreaAudioCannon2_body_entered(_body):
	GameState.cannon1_active = !GameState.cannon1_active


func _on_AreaAudioCannon2_body_exited(_body):
	GameState.cannon1_active = !GameState.cannon1_active


func _on_AreaAudioCannon3_body_entered(_body):
	GameState.cannon1_active = !GameState.cannon1_active


func _on_AreaAudioCannon3_body_exited(_body):
	GameState.cannon1_active = !GameState.cannon1_active


func play(bgm):
	pass # Replace with function body.
