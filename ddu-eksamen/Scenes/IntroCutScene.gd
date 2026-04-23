extends Node2D




func _on_animated_sprite_2d_animation_finished() -> void:
	Global.SceneChanger.load_scene("Menu")
	pass # Replace with function body.
