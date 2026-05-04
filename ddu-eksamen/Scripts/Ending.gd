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

var range_mod=7.66
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AudioStreamPlayer2D.volume_db = -50 + range_mod*log(Global.volume) + range_mod*log(Global.volume_music)

	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	Global.SceneChanger.load_scene("Menu")
