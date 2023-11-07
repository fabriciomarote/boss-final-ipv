extends Control

## Escena que presenta la información que figura en pantalla durante
## el juego. Maneja tanto lo que es barras de salud como información
## general.

const attackModes = preload("res://src/game/entities/AttackModes.gd")

onready var stamina_progress: TextureProgress = $"%StaminaProgress"
onready var hp_progress: TextureProgress = $"%HpProgress"
onready var bow: Sprite = $StatsContainer/Panel/Bow
onready var axe: Sprite = $StatsContainer/Panel/Axe
onready var counter: Sprite = $StatsContainer/Panel/Counter

onready var fading_elements: Array = [hp_progress, stamina_progress]

export (float) var fade_duration: float = 5.0
export (float) var fade_delay: float = 2.0

var stats_tween: SceneTreeTween


# Recupera la información de cuál es el Player actual desde GameState.
func _ready() -> void:
	GameState.connect("current_player_changed", self, "_on_current_player_changed")


## Cuando se asigna un Player nuevo, se conecta a las señales que
## interesan, y se refresca la data.
func _on_current_player_changed(player: Player) -> void:
	player.connect("hp_changed", self, "_on_hp_changed")
	_on_hp_changed(player.hp, player.max_hp)
	player.connect("stamina_changed", self, "_on_stamina_changed")
	_on_stamina_changed(player.stamina, player.max_stamina)
	player.connect("weapon_changed", self, "_on_weapon_changed")
	_on_weapon_changed(player.currentAttackMode)


func _on_hp_changed(hp: int, hp_max: int) -> void:
	hp_progress.max_value = hp_max
	hp_progress.value = hp
	_animate_fade()


func _on_stamina_changed(stamina: float, max_stamina: float) -> void:
	stamina_progress.max_value = max_stamina
	stamina_progress.value = stamina
	_animate_fade()


func _on_weapon_changed(weaponPlayer: int) -> void:
	if weaponPlayer == 1:
		axe.visible = true
		bow.visible = false
		counter.visible = false
	else:
		bow.visible = true
		axe.visible = false
		counter.visible = true


# Función de ayuda para animar el fade-out de elementos de la escena.
func _animate_fade() -> void:
	if !is_inside_tree():
		return
	
	if stats_tween:
		stats_tween.kill()
	stats_tween = create_tween()
	
	for element in fading_elements:
		element.modulate = Color.white
		stats_tween.set_parallel().tween_property(element, "modulate", Color.white, fade_duration).set_trans(Tween.TRANS_SINE).set_delay(fade_delay)
