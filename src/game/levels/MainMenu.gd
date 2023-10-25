extends Node

export (PackedScene) var level_manager_scene: PackedScene


func _ready():
	pass # Replace with function body.



func _on_StartButton_pressed():
	pass
	#get_tree().change_scene_to(level_manager_scene)
	get_tree().change_scene("res://src/game/levels/Level01.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_OptionsButton_pressed():
	pass # Replace with function body.
