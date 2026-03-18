extends CanvasLayer

@onready var happiness_bar = $"HappinessBar/HappinessBarColorRect"
@onready var bar_sprite_1 = $HappinessBar/BarSprite1
@onready var buttons = $MenuButtons.get_children()
@onready var root_menu = $RootMenu

const bar_max_width = 768.0  # 2/5 of 1920
const bar_height = 30
const lerp_speed = 0.1
const menu_offset = Vector2(0,0)
const root_closed_pos = Vector2(1920,0)
const root_open_pos = Vector2(1700,0)
const screen_dim = Vector2(1920, 1080)

var root_open = false

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
	
	#Menu Buttons
	for button in buttons:
		button.z_index = 8
	buttons[0].set_position(Vector2(0, screen_dim.y/5+10-31)+menu_offset) 
	buttons[1].set_position(Vector2(31, screen_dim.y/5+10-31)+menu_offset)
	buttons[2].set_position(Vector2(31*2, screen_dim.y/5+10-31)+menu_offset)
	buttons[3].set_position(Vector2(31*3, screen_dim.y/5+10-31)+menu_offset)
	buttons[4].set_position(Vector2(0, screen_dim.y/5+10)+menu_offset)
	buttons[5].set_position(Vector2(31, screen_dim.y/5+10)+menu_offset)
	buttons[6].set_position(Vector2(31*2, screen_dim.y/5+10)+menu_offset)
	buttons[7].set_position(Vector2(31*3, screen_dim.y/5+10)+menu_offset)
	
	#Menus
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))

func update_happiness_bar(delta: float) -> void:
	var target_width = (Global.average_happiness / 100.0) * (2 * screen_dim.x / 5)
	var target_size = Vector2(target_width, bar_height)
	happiness_bar.size = happiness_bar.size.lerp(target_size, 1.0 - pow(lerp_speed, delta))

func update_menus(delta: float) -> void:
	var root_pos
	if root_open:
		root_pos = root_open_pos
	else:
		root_pos = root_closed_pos
	root_menu.position = root_menu.position.lerp(root_pos, 1.0-pow(lerp_speed, delta))
	pass

func _ready() -> void:
	position_elements()
	# Set initial size based on current happiness
	var initial_width = (Global.average_happiness / 100.0) * (2 * screen_dim.x / 5)
	happiness_bar.size = Vector2(initial_width, bar_height)

func _process(delta: float) -> void:
	update_happiness_bar(delta)
	update_menus(delta)

func _on_button_pressed(button):
	if button == buttons[0]:
		print("button 1")
	if button == buttons[1]:
		print("button 2")
	if button == buttons[2]:
		print("button 3")
		if root_open:
			root_open = false
		else:
			root_open = true
	if button == buttons[3]:
		print("button 4")
	if button == buttons[4]:
		print("button 5")
	if button == buttons[5]:
		print("button 6")
	if button == buttons[6]:
		print("button 7")
	if button == buttons[7]:
		print("button 8")
