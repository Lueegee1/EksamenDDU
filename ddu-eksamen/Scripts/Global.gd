extends Node2D
#class prototype for colonist i guess
var research_points: int = 0
var food: int = 0
var plant_matter: int = 0
var minerals: int = 0

var timer: float = 0
var tick_interval: float = 1.0

var Constants
var GameController

#func _ready() -> void:
#	pass # Replace with function body.

func tick():
	emit_signal("tick_signal")
	pass
	#Food
	#Spawn new colonist
	#Ressources
	#Spawn events

func _process(delta: float) -> void:
	timer += delta
	if timer > tick_interval:
		tick()
		timer = 0 



	
