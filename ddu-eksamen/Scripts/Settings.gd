extends Node2D

const SAVE_FILE = "user://database.json"
var value_changed = false
var wins
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_labels()
	pass

func hard_reset():
	var has_save = true
	if not FileAccess.file_exists(SAVE_FILE): #checker om save filen eksiterer
		has_save = false
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ) #opens the file and saves it in read mode as variable file and checks if opening
#it was succesfull
	if file == null:
		has_save = false
	var save_text = file.get_as_text()
	file.close()
	var json_save_data = JSON.new()
	var parsed_json_save_data = json_save_data.parse(save_text)
	if parsed_json_save_data != OK: #checks if the json was parsed succesfully
		has_save = false
	if has_save:
		var saved_data = json_save_data.data
		if FileAccess.file_exists(SAVE_FILE):
			DirAccess.remove_absolute(SAVE_FILE)
			
func _on_button_pressed() -> void:
	$CanvasLayer/Popup.visible = true
	
	pass # Replace with function body.


func _on_volume_value_changed(value: float) -> void:
	Global.volume= value
	value_changed = true
	print("Master volume set to" + str(Global.volume))
	pass # Replace with function body.


func _on_hard_reset_pressed() -> void:
	hard_reset()
	value_changed = true
	$CanvasLayer/Popup.visible = false
	pass # Replace with function body.


func _on_cancel_pressed() -> void:
	$CanvasLayer/Popup.visible = false
	pass # Replace with function body.


func _on_volume_2_value_changed(value: float) -> void:
	Global.volume_music = value
	value_changed = true
	print("Music volume set to" + str(Global.volume_music))

	pass # Replace with function body.


func _on_volume_3_value_changed(value: float) -> void:
	Global.volume_effect = value
	value_changed = true

	print("Effect volume set to" + str(Global.volume_effect))

func update_labels():
	if not value_changed:
		return
	$CanvasLayer/Volume/VolumeLabel.text = "Master Volume: " + str(round(Global.volume))
	$CanvasLayer/Volume.value =Global.volume
	$CanvasLayer/Volume2/VolumeLabel.text = "Music Volume: " + str(round(Global.volume_music))
	$CanvasLayer/Volume2.value = Global.volume_music
	$CanvasLayer/Volume3/VolumeLabel.text = "Sound Volume: " + str(round(Global.volume_effect))
	$CanvasLayer/Volume3.value = Global.volume_effect
	print(Global.volume_effect)
	load_wins()
	if len(wins) >=1:
		$CanvasLayer/GameSpeed/SpeedLabel.text = "Current Game Speed " + str(round(Global.tick_interval))
		$CanvasLayer/GameSpeed.editable = true
	else:
		$CanvasLayer/GameSpeed.editable = false
		$CanvasLayer/GameSpeed/SpeedLabel.text = "Get one win to change game speed"
	
	value_changed =false

func load_wins():
	wins=  []
	var has_save = true
	if not FileAccess.file_exists(SAVE_FILE): #checker om save filen eksiterer
		has_save = false
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ) #opens the file and saves it in read mode as variable file and checks if opening
#it was succesfull
	if file == null:
		has_save = false
		return
	var save_text = file.get_as_text()
	file.close()
	var json_save_data = JSON.new()
	var parsed_json_save_data = json_save_data.parse(save_text)
	if parsed_json_save_data != OK: #checks if the json was parsed succesfully
		has_save = false
	if has_save:
		var saved_data = json_save_data.data
		if "achieved_wins" not in saved_data:
			return
		var achieved_wins = saved_data["achieved_wins"]
		if saved_data.has("achieved_wins"):
			wins = achieved_wins.get("wins")
	else:
		return

func _on_game_speed_value_changed(value: float) -> void:
	Global.tick_interval = value
	value_changed = true
	pass # Replace with function body.


func _on_texture_button_pressed() -> void:
	Global.GameManager.save_game()
	queue_free()
	pass # Replace with function body.
