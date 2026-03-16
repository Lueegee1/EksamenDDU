extends CanvasLayer

@onready var happiness_bar = $"HappinessBar/HappinessBarColorRect"

var bar_length = 200
var screen_dim= Vector2(1920,1080)
func position_elements():
	#Happiness bar
	happiness_bar.position = Vector2(((screen_dim.x-bar_length)/2),50)
	happiness_bar.size=Vector2(bar_length,30)
	happiness_bar.color = Color(0.231, 1.0, 0.302, 1.0)

func _ready() -> void:
	position_elements()

func update_happiness_bar():
	bar_length = (Global.average_happiness/100)*(2*screen_dim.x/5)


func _process(delta: float) -> void:
	delta = delta
	update_happiness_bar()
