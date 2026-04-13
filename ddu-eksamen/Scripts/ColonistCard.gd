extends Control

@onready var name_tag = $Label
@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WorkButton.get_popup().id_pressed.connect(_on_work_pressed)
	$HouseButton.get_popup().id_pressed.connect(_on_house_pressed)

	pass # Replace with function body.

func _on_work_pressed(id) -> void:
	var popup = $WorkButton.get_popup()
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
	Global.GameManager.assign_colonist_to_workplace(name_tag.text, workplace)
	print(name_tag.text + " was assigned to " + Global.GameManager.workers_dict[name_tag.text])

func _on_house_pressed(id) -> void:
	var popup = $HouseButton.get_popup()
	var index = popup.get_item_index(id)
	var house: String
	match id:
		0: house = "house1"
		1: house = "house2"
		2: house = "house3"
		3: house = "house4"
		4: house = "homeless"
	
#	if Global.GameManager.assign_colonist_to_house(name_tag.text, str(house)):
		
	# Uncheck all items first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
	
	# Check the one that was pressed
		popup.set_item_checked(index, true)
		#print(Global.GameManager.housing_dictionary[house])
		if house in Global.GameManager.housing_dictionary:
			Global.GameManager.assign_colonist_to_house(name_tag.text, house)
		
func update_work_checkbox(workplace: String) -> void:
	var popup = $WorkButton.get_popup()
		
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
	$WorkButton.text = "Currently: " + workplace + "
	Assign to"
func update_house_checkbox() -> void:
	var house
	for i in Global.GameManager.housing_dictionary:
		for j in Global.GameManager.housing_dictionary[i]["assigned"]:
			if j == name_tag.text:
				house = i
	
	var popup = $HouseButton.get_popup()
		
		# Uncheck all first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
		
		# Check the matching item
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
		$HouseButton.text = "Bro is a bum"
	else:
		$HouseButton.text = "Currently: " + str(house) + "
		Assign to"

func setup(colonist_name, colonist_sprite):
	sprite.texture = load(colonist_sprite)
	name_tag.text = colonist_name
	pass
# Called every frame. 'delta' is the elapsed time since the u frame.
func _process(delta: float) -> void:
	update_work_checkbox(Global.GameManager.workers_dict[name_tag.text])
	update_house_checkbox()
	pass
