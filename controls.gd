extends Control

func _input(event):
	if event.is_action_pressed("dash"):
		get_tree().change_scene_to_file("res://root.tscn")
