extends Control

var level = 0
var current_price: Array
var index
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func setup(number):
	index = number
	current_price = Global.GameManager.house_price
	$Group1/Label.text = "House " + str(number)
	$Group1/Label2.text = "  Cost: " + "
	" + str(Global.GameManager.house_price[0]) +"
	" + str(Global.GameManager.house_price[1])
	if "house" +str(index) in Global.GameManager.housing_dictionary:
		level =int(Global.GameManager.housing_dictionary["house"+str(index)]["capacity"])
	pass

func update_price_label():
	$Group1/Label2.text = "    Cost: " + "
	" + str(current_price[0]) +"
	" + str(current_price[1])

func update_price():
	if level == 0:
		current_price = Global.GameManager.house_price
		update_price_label()
	if level ==1:
		$Group1/Label4.text = "Upgrade: "
		current_price = Global.GameManager.house_upgrade1_price
		update_price_label()
	if level ==2:
		$Group1/Label2.text = "This building is fully
		upgraded"
		$Group1/SpriteGroup/Sprite2D.visible = false
		$Group1/SpriteGroup/Sprite2D2.visible = false
	
	pass
 
func update_buttons():
	if Global.minerals < current_price[0] or Global.plant_matter < current_price[1]:
		$Group1/TextureButton2.disabled = true
	if level == 0 and Global.GameManager.researches[7]["researched"] == 0:
		$Group1/TextureButton2.disabled = true
	if level == 1 and Global.GameManager.researches[9]["researched"] == 0:
		$Group1/TextureButton2.disabled = true
	else:
		$Group1/TextureButton2.disabled = false
	


func update_name():
	var type
	match level:
		0: type = "Empty plot"
		1: type = "Tent"
		2: type = "House"
	$Group1/Label.text = type + " " + str(index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if str(index) == "null_card":
		if Global.UI.house_count > 0:
			Global.UI.build_card_dict.erase("null_card")
			queue_free()
		for item in $Group1.get_children():
			item.visible = false
		$Group1/Label.visible = true
		$Group1/Label.text = "You cannot construct any houses currently"
		return
	update_buttons()
	update_price()
	update_name()

	pass


func _on_build_button_pressed() -> void:
	Global.GameManager.Click()
	match level:
		2: return
		1: Global.GameManager.upgrade_building("house"+str(index)); level +=1
		0: Global.GameManager.build_new_building("house"); level +=1
