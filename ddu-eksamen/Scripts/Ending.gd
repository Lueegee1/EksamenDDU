extends Node2D
@onready var animation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match Global.win_flag:
		"Eugenics": animation.play("Eugenics")
		"Pod": animation.play("Pod")
		"Cult": animation.play("Cult")
		"Death":animation.play("Death")

		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	Global.SceneChanger.load_scene("Menu")
