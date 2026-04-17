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
	$Group1/Label2.text = "Cost " + "
	" + str(Global.GameManager.house_price[0]) +"
	" + str(Global.GameManager.house_price[1])
	pass

func update_price_label():
	$Group1/Label2.text = "Cost " + "
	" + str(current_price[0]) +"
	" + str(current_price[1])

func update_price():
	if level == 0:
		current_price = Global.GameManager.house_price
		update_price_label()
	if level ==1:
		current_price = Global.GameManager.house_upgrade1_price
		update_price_label()
	if level ==2:
		$Group1/Label2.text = "This building is fully
		upgraded"
	pass

func update_buttons():
	if level > 0 or Global.minerals < current_price[0] or Global.plant_matter < current_price[1]:
		$Group1/TextureButton2.disabled = true
	else:
		$Group1/TextureButton2.disabled = false
	if level == 0 or Global.minerals < current_price[0] or Global.plant_matter < current_price[1] or Global.GameManager.researches[9]["researched"] == 0 or not Global.GameManager.can_upgrade_building("house" +str(index)):
		$Group1/TextureButton.disabled = true
	else:
		$Group1/TextureButton.disabled = false
	pass

func update_name():
	var type
	match level:
		0: type = "Empty plot"
		1: type = "Tent"
		2: type = "House"
	$Group1/Label.text = type + " " + str(index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_buttons()
	update_price()
	update_name()
	pass


func _on_build_button_pressed() -> void:
	Global.GameManager.build_new_building("house")
	level +=1
	pass # Replace with function body.


func _on_upgrade_button_pressed() -> void:
	if level == 2:
		return
	Global.GameManager.upgrade_building("house"+str(index))
	level +=1
	pass # Replace with function body.
