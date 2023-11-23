tool
extends Node

onready var bus_name_label: Label = $"%BusNameLabel"
onready var mute_button: Button = $"%MuteButton"
onready var sound_slider: HSlider = $"%SoundSlider"

export (String) var bus_name: String setget _set_bus_name
export (PoolRealArray) var values_range: PoolRealArray = PoolRealArray([-80.0, 0.0]) setget _set_values_range


func _set_bus_name(bus: String) -> void:
	bus_name = bus
	if has_node("%BusNameLabel"):
		bus_name_label = $"%BusNameLabel"
		bus_name_label.text = bus_name
	if !bus_name.empty() && has_node("%MuteButton"):
		mute_button = $"%MuteButton"
		mute_button.pressed = AudioServer.is_bus_mute(
			AudioServer.get_bus_index(bus_name)
		)


func _set_values_range(values: PoolRealArray) -> void:
	values.resize(2)
	values_range = values
	if has_node("%SoundSlider"):
		sound_slider = $"%SoundSlider"
		sound_slider.min_value = values_range[0]
		sound_slider.max_value = values_range[1]
		if !bus_name.empty():
			sound_slider.value = AudioServer.get_bus_volume_db(
				AudioServer.get_bus_index(bus_name)
			)


func _ready() -> void:
	sound_slider.min_value = values_range[0]
	sound_slider.max_value = values_range[1]
	if !bus_name.empty():
		bus_name_label.text = bus_name
		sound_slider.value = AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index(bus_name)
		)
		mute_button.pressed = AudioServer.is_bus_mute(
			AudioServer.get_bus_index(bus_name)
		)


func _on_MuteButton_toggled(button_pressed: bool) -> void:
	if !bus_name.empty():
		AudioServer.set_bus_mute(
			AudioServer.get_bus_index(bus_name),
			button_pressed
		)


func _on_SoundSlider_value_changed(value: float) -> void:
	if !bus_name.empty():
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(bus_name),
			value
		)
