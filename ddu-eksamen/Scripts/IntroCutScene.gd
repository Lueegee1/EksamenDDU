extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	await get_tree().create_timer(0.27).timeout
	$AudioStreamPlayer2D.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	Global.SceneChanger.load_scene("Game")
	pass # Replace with function body.
