extends CanvasLayer

@onready var happiness_bar = $"HappinessBar/HappinessBarColorRect"

var bar_length = 500
var screen_dim= Vector2(1152,648)
func position_elements():
	#Happiness bar
	happiness_bar.position = Vector2(((screen_dim.x-bar_length)/2),50)
	happiness_bar.size=Vector2(bar_length,50)

func _ready() -> void:
	position_elements()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
