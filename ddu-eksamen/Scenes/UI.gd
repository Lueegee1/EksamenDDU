extends CanvasLayer

@onready var happiness_bar = $"HappinessBar/HappinessBarColorRect"
@onready var bar_sprite_1 = $HappinessBar/BarSprite1

const bar_max_width = 768.0  # 2/5 of 1920
const bar_height = 30
const lerp_speed = 0.1

var screen_dim = Vector2(1920, 1080)

func position_elements() -> void:
	#Bar
	var max_width = 2 * screen_dim.x / 5
	happiness_bar.position = Vector2((screen_dim.x - max_width) / 2, 50)
	happiness_bar.color = Color(0.231, 1.0, 0.302, 1.0)
	happiness_bar.z_index=10
	@warning_ignore("integer_division")
	bar_sprite_1.position = Vector2(bar_max_width/2+screen_dim.x*0.3,50+bar_height/2)
	bar_sprite_1.scale=Vector2(4,4)
	bar_sprite_1.z_index=9

func update_happiness_bar(delta: float) -> void:
	var target_width = (Global.average_happiness / 100.0) * (2 * screen_dim.x / 5)
	var target_size = Vector2(target_width, bar_height)
	happiness_bar.size = happiness_bar.size.lerp(target_size, 1.0 - pow(lerp_speed, delta))

func _ready() -> void:
	position_elements()
	# Set initial size based on current happiness
	var initial_width = (Global.average_happiness / 100.0) * (2 * screen_dim.x / 5)
	happiness_bar.size = Vector2(initial_width, bar_height)

func _process(delta: float) -> void:
	update_happiness_bar(delta)
