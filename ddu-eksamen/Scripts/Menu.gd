extends Node2D




func _on_button_1_pressed() -> void:
	#Global.SceneChanger.load_scene("IntroCutScene")
	Global.SceneChanger.load_scene("Game")


func _on_button_2_pressed() -> void:
	Global.has_save_file = false
	Global.SceneChanger.load_scene("Game")
	pass # Replace with function body.
