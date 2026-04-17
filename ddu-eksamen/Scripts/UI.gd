extends CanvasLayer

@onready var happiness_bar = $"HappinessBar/HappinessBarColorRect"
@onready var bar_sprite_1 = $HappinessBar/BarSprite1
@onready var buttons = $MenuButtons.get_children()
@onready var root_menu = $RootMenu
@onready var build_menu = $RootMenu/BuildScroll
@onready var research_menu = $RootMenu/ResearchScroll
@onready var work_menu = $RootMenu/WorkMenu
@onready var colonist_menu = $RootMenu/ColonistScroll

const character_card = preload("res://Scenes/ColonistCard.tscn")
const research_card = preload("res://Scenes/ResearchCard.tscn")
const build_card = preload("res://Scenes/BuildCard.tscn")
const bar_max_width = 768.0  # 2/5 of 1920
const bar_height = 30
const lerp_speed = 0.1
const menu_offset = Vector2(0,12)
const root_closed_pos = Vector2(1920,screen_dim.y/20)
@warning_ignore("integer_division")
const root_open_pos = Vector2(3*1920/4,screen_dim.y/20)
const screen_dim = Vector2(1920, 1080)

var root_open = false
var build_open = false
var research_open = false
var colonist_open = false

var colonists_card_dict: Dictionary = {}
var research_card_dict: Dictionary ={}
var build_card_dict: Dictionary = {}
var house_count = 0

func position_elements() -> void:
	#Bar
	var max_width = 2 * screen_dim.x / 5
	happiness_bar.position = Vector2((screen_dim.x - max_width) / 2, 50)
	happiness_bar.color = Color(0.231, 1.0, 0.302, 1.0)
	happiness_bar.z_index=10
	$HappinessBar/Label.z_index =11
	@warning_ignore("integer_division")
	bar_sprite_1.position = Vector2(bar_max_width/2+screen_dim.x*0.3,50+bar_height/2)
	bar_sprite_1.scale=Vector2(4,4)
	bar_sprite_1.z_index=9
	
	#Buttons
	for button in buttons:
		button.z_index = 8
	buttons[0].set_position(Vector2(0, screen_dim.y/5+10-31)+menu_offset) 
	buttons[1].set_position(Vector2(31, screen_dim.y/5+10-31)+menu_offset)
	buttons[2].set_position(Vector2(root_closed_pos.x*0.285, 0))
	buttons[3].set_position(Vector2(root_closed_pos.x*0.285+(1*0.45*30),0))
	buttons[4].set_position(Vector2(0, screen_dim.y/5+10)+menu_offset)
	buttons[5].set_position(Vector2(root_closed_pos.x*0.285+(2*0.45*30),0))
	buttons[6].set_position(Vector2(31*2, screen_dim.y/5+10)+menu_offset)
	buttons[7].set_position(Vector2(root_open_pos.x*0.285,0) + Vector2(4*0.45*31,0))	
	buttons[8].set_position(Vector2(screen_dim.x/5+74, screen_dim.y/12))
	
	#Menus
	for button in buttons:
		button.pressed.connect(_on_button_pressed.bind(button))
	root_menu.position=root_closed_pos	

func update_happiness_bar(delta: float) -> void:
	var target_width = (Global.average_happiness / 100.0) * (2 * screen_dim.x / 5)
	var target_size = Vector2(target_width, bar_height)
	happiness_bar.size = happiness_bar.size.lerp(target_size, 1.0 - pow(lerp_speed, delta))
	$HappinessBar/Label.position = happiness_bar.position + Vector2((screen_dim.x -400)/ 5,0)
	$HappinessBar/Label.text = "Average happiness " +str(clamp(round(Global.average_happiness),0,100)) + "/100"
	
func update_menus(delta: float) -> void:
	var root_pos
	if root_open:
		root_pos = root_open_pos
	else:
		root_pos = root_closed_pos
	var speed = 500 # pixels per second

	root_menu.position.x = move_toward(root_menu.position.x, root_pos.x, speed * delta)
	buttons[2].position.x =move_toward(buttons[2].position.x,root_pos.x*0.285, 0.27*speed*delta)
	buttons[3].position.x =move_toward(buttons[3].position.x,root_pos.x*0.285+(1*0.45*30), 0.27*speed*delta)
	buttons[5].position.x =move_toward(buttons[5].position.x,root_pos.x*0.285+(2*0.45*30), 0.27*speed*delta)
	buttons[8].position.x = move_toward(buttons[8].position.x, (screen_dim.x/5+78) +(2+root_pos.x**1.001-root_closed_pos.x**1.001)/4, 0.255*speed*delta)
	#Unreadable logic
	if not build_open:
		build_menu.visible = false
	else:
		build_menu.visible = true
	if not research_open:
		research_menu.visible = false
	else:
		research_menu.visible = true
	if not colonist_open:
		colonist_menu.visible = false
	else:
		colonist_menu.visible = true
	
	#Make colonist menu
	for character in Global.GameManager.colonist_dict:
		if character not in colonists_card_dict:
			var card = character_card.instantiate()
			$RootMenu/ColonistScroll/ColonistMenu.add_child(card)
			card.setup(character, "res://Assets/temp files/buttons/Sprite-0003-Sheet3.png")
			colonists_card_dict[character] = card

	var to_remove = []
	for character in colonists_card_dict:
		if character not in Global.GameManager.colonist_dict:
			to_remove.append(character)
	for character in to_remove:
		$RootMenu/ColonistScroll/ColonistMenu.remove_child(colonists_card_dict[character])
		colonists_card_dict.erase(character)
	
	#Make research menu
	for research in range(Global.GameManager.researches.size()):
		research +=1
		if Global.GameManager.meet_research_requirements(research) == true and research not in research_card_dict: 
			var card = research_card.instantiate()
			$RootMenu/ResearchScroll/ResearchMenu.add_child(card)
			card.setup(research)
			research_card_dict[research] = card

	var to_remove2 = []
	for research in research_card_dict:
		if not Global.GameManager.meet_research_requirements(research):
			to_remove2.append(research)
	for research in to_remove2:
		$RootMenu/ResearchScroll/ResearchMenu.remove_child(research_card_dict[research])
		research_card_dict.erase(research)
	
	#Make Building Menu
	
	var build_type ="house"
	if Global.GameManager.can_build_building(build_type) and house_count < 4 and len(Global.GameManager.housing_dictionary) >= house_count+1:
		house_count +=1
		var card = build_card.instantiate()
		$RootMenu/BuildScroll/BuildMenu.add_child(card)
		card.setup(house_count)
		build_card_dict[build_type] = card
			
func update_ressources():
	$Ressources.text =str(round(Global.plant_matter*10)/10) + "
	" + str(round(Global.minerals*10)/10) + "
	" + str(round(Global.food*10)/10) + "
	" + str(round(Global.research_points*10)/10)
	

func _ready() -> void:
	position_elements()
	# Set initial size based on current happiness
	#var initial_width = (Global.average_happiness / 100.0) * (2 * screen_dim.x / 5)
	happiness_bar.size = Vector2(0, bar_height)

func _process(delta: float) -> void:
	update_happiness_bar(delta)
	update_menus(delta)
	update_ressources()
	

func _on_button_pressed(button):
	if button == buttons[0]:
		print("button 1")
	if button == buttons[1]:
		print("button 2")
	if button == buttons[2]:
		print("button 3")
		if root_open and not build_open and not research_open:
			pass
		else:
			colonist_open = true
			build_open = false
			research_open = false
	if button == buttons[3]:
		print("button 4")
		if root_open and not colonist_open and not research_open:
			pass
		else:
			build_open = true
			research_open = false
			colonist_open = false
	if button == buttons[4]:
		print("button 5")
	if button == buttons[5]:
		print("button 6")
		if root_open and not colonist_open and not build_open:
			pass
		else:
			research_open = true
			colonist_open = false
			build_open = false
	if button == buttons[6]:
		Global.GameManager.kill_colonist($RootMenu/ColonistScroll/ColonistMenu.get_child(1).name_tag.text)
		print("button 7")
	if button == buttons[7]:
		print("button 8")
	if button == buttons[8]:
		print("button 9")
		if not research_open and not build_open and not colonist_open:
			colonist_open = true 
		if root_open:
			root_open = false
		else:
			root_open = true
		print(root_open)
	
