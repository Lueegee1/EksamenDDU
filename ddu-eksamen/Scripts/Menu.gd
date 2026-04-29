extends Node2D

const SAVE_FILE = "user://database.json"
var wins


func _on_button_1_pressed() -> void:
	#Global.SceneChanger.load_scene("IntroCutScene")
	Global.load_game = true
	Global.SceneChanger.load_scene("Game")


func _on_button_2_pressed() -> void:
	Global.load_game = false
	Global.SceneChanger.load_scene("Game")
	pass # Replace with function body.
	
	
func load_wins():
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
		if "achieved_wins" not in saved_data:
			return
		var achieved_wins = saved_data["achieved_wins"]
		if saved_data.has("achieved_wins"):
			wins = achieved_wins.get("wins")
	else:
		return

func _process(delta: float) -> void:
	load_wins()
	$MenuUI/Label.text = str(wins)
