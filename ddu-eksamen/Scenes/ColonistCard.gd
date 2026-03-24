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
	if id == 0:
		house = "house1"
	if id == 1:
		house = "house2"
	if id == 2:
		house = "house3"
	if id == 3:
		house = "house4"
	
#	if Global.GameManager.assign_colonist_to_house(name_tag.text, str(house)):
		
	# Uncheck all items first
	for i in popup.item_count:
		popup.set_item_checked(i, false)
	
	# Check the one that was pressed
		popup.set_item_checked(index, true)
		#print(Global.GameManager.housing_dictionary[house])
	
func setup(colonist_name, colonist_sprite):
	sprite.texture = load(colonist_sprite)
	name_tag.text = colonist_name
	pass
# Called every frame. 'delta' is the elapsed time since the u frame.
func _process(delta: float) -> void:
	pass
