tool
extends Control

onready var action_name_label: Label = $"%ActionNameLabel"
onready var action_key_button: Button = $"%ActionKeyButton"

export (String) var action: String
export (String) var action_name: String setget _set_action_name

func _ready():
	set_process_input(false)
	if !Engine.editor_hint && InputMap.has_action(action):
		var event: InputEvent = InputMap.get_action_list(action)[0]
		_set_event(event)


func _input(event: InputEvent) -> void:
	if !event is InputEventMouseMotion:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		_set_event(event)
		set_process_input(false)
		GameState.notify_input_map_changed()
		yield(get_tree().create_timer(0.1), "timeout")
		action_key_button.grab_focus()


func _set_event(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		action_key_button.text = event.as_text().get_slice(":", 1).get_slice(",", 0).get_slice("=", 1)
	else:
		action_key_button.text = event.as_text()


func _set_action_name(nm: String) -> void:
	action_name = nm
	if has_node("%ActionNameLabel"):
		$"%ActionNameLabel".text = nm


func _on_ActionKeyButton_pressed():
	set_process_input(true)
	action_key_button.text = "..."
	action_key_button.release_focus()
