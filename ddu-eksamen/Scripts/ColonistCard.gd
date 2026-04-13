extends Control

@onready var name_tag = $Group1/Label
@onready var sprite = $Group1/TextureRect
@onready var workbutton = $Group1/WorkButton
@onready var housebutton = $Group1/HouseButton
@onready var actionbutton = $Group1/ActionButton
var name_of_colonist
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	workbutton.get_popup().id_pressed.connect(_on_work_pressed)
	housebutton.get_popup().id_pressed.connect(_on_house_pressed)
	actionbutton.get_popup().id_pressed.connect(_on_action_pressed)
	pass # Replace with function body.

func _on_work_pressed(id) -> void:
	var popup = workbutton.get_popup()
	var index = popup.get_item_index(id)
	
	# Uncheck all items first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
	
	# Check the one that was pressed
	popup.set_item_checked(index, true)
	var workplace: String
	if id == 0:
		workplace = "farm"
	if id == 1:
		workplace = "mine"
	if id == 2:
		workplace = "plants"
	if id ==3:
		workplace = "research_lab"
	if id ==4:
		workplace = "unemployed"
	Global.GameManager.assign_colonist_to_workplace(name_of_colonist, workplace)
	print(name_of_colonist + " was assigned to " + Global.GameManager.workers_dict[name_of_colonist])

func _on_house_pressed(id) -> void:
	var popup = housebutton.get_popup()
	var index = popup.get_item_index(id)
	var house: String
	match id:
		0: house = "house1"
		1: house = "house2"
		2: house = "house3"
		3: house = "house4"
		4: house = "homeless"
	
#	if Global.GameManager.assign_colonist_to_house(name_of_colonist, str(house)):
		
	# Uncheck all items first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
	
	# Check the one that was pressed
		popup.set_item_checked(index, true)
		#print(Global.GameManager.housing_dictionary[house])
		if house in Global.GameManager.housing_dictionary:
			Global.GameManager.assign_colonist_to_house(name_of_colonist, house)
		
func update_work_checkbox(workplace: String) -> void:
	var popup = workbutton.get_popup()
		
		# Uncheck all first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
		
		# Check the matching item
	match workplace:
		"farm": popup.set_item_checked(1, true)
		"mine": popup.set_item_checked(2, true)
		"plants": popup.set_item_checked(3, true)
		"research_lab": popup.set_item_checked(4, true)
		"unemployed": popup.set_item_checked(0, true)
	match workplace:
		"farm": workplace = "Foraging"
		"mine": workplace ="Mining"
		"plants": workplace = "Lumbering"
		"research_lab": workplace= "Studying"
		"unemployed": workplace="Leisure"
	workbutton.text = "Currently: " + workplace + "
	Assign to"
func update_house_checkbox() -> void:
	var house
	for i in Global.GameManager.housing_dictionary:
		for j in Global.GameManager.housing_dictionary[i]["assigned"]:
			if j == name_of_colonist:
				house = i
	
	var popup = housebutton.get_popup()
		

	for i in popup.item_count:
		popup.set_item_checked(i, false)

	match house:
		"house1": popup.set_item_checked(1, true)
		"house2": popup.set_item_checked(2, true)
		"house3": popup.set_item_checked(3, true)
		"house4": popup.set_item_checked(4, true)
		"not_built":popup.set_item_checked(0, true)
		null: popup.set_item_checked(0, true)
	match house:
		"house1": house = "House 1"
		"house2": house ="House 2"
		"house3": house = "House 3"
		"house4": house= "House 4"
		"not_built": house= "Homeless"
		null: house= "Homeless"
	if house == "Homeless":
		housebutton.text = "Bro is a bum"
	else:
		housebutton.text = "Currently: " + str(house) + "
		Assign to"

func setup(colonist_name, colonist_sprite):
	name_of_colonist = colonist_name
	sprite.texture = load(colonist_sprite) as Texture2D
	name_tag.text = str(colonist_name) + "
	Happiness: " + str(Global.GameManager.happiness_dict[colonist_name]["happiness"])
	
	pass

func _on_action_pressed(id):
	match id:
		0: Global.GameManager.kill_colonist(name_of_colonist)
		1: Global.GameManager.kill_colonist(name_of_colonist)
		2: show_hide_genes()

func update_actions():
	var popup = actionbutton.get_popup()
	if Global.GameManager.researches[24]["researched"]==1:
		popup.set_item_disabled(0, false)
	else:
		popup.set_item_disabled(0, true)
	
	if Global.GameManager.researches[23]["researched"]==1:
		popup.set_item_disabled(1, false)
	else:
		popup.set_item_disabled(1, true)
	
	if Global.GameManager.researches[20]["researched"]==1:
		popup.set_item_disabled(2, false)
	else:
		popup.set_item_disabled(2, true)

func _process(delta: float) -> void:
	update_work_checkbox(Global.GameManager.workers_dict[name_of_colonist])
	update_house_checkbox()
	update_actions()
	name_tag.text = str(name_of_colonist) + "
	Happiness: " + str(round(Global.GameManager.happiness_dict[name_of_colonist]["happiness"]), 1)
	pass

func show_hide_genes():
	if $Group1.visible:
		$Group1.visible = false
		$Group2.visible = true
	else:
		$Group1.visible = true
		$Group2.visible = false

func _on_gene_button_pressed() -> void:
	show_hide_genes()
