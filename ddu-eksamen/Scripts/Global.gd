extends Node2D
#class prototype for colonist i guess
var research_points: float = 1000
var food: float = 10000
var plant_matter: float = 10000
var minerals: float = 10000
var decorations: int = -10
var average_happiness: float = 0
const SAVE_FILE = "user://database.json"
var timer: float = 0
var tick_interval: float = 1.0
var load_game = false
var volume = 20
var volume_music = 20
var volume_effect = 20

var UI
var SceneChanger
var GameManager

func load_globals() -> bool:
	print("Save file exists: ", FileAccess.file_exists(SAVE_FILE))
	print("Save path: ", SAVE_FILE)
	if not FileAccess.file_exists(SAVE_FILE): #checker om save filen eksiterer
		return false
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ) #opens the file and saves it in read mode as variable file and checks if opening
#it was succesfull
	if file == null:
		return false
	var save_text = file.get_as_text()
	file.close()
	var json_save_data = JSON.new()
	var parsed_json_save_data = json_save_data.parse(save_text)
	if parsed_json_save_data != OK: #checks if the json was parsed succesfully
		return false
	var saved_data = json_save_data.data
	if saved_data.has("globals"):
		var globals= saved_data["globals"]
		Global.tick_interval= globals.get("tick_interval")
		Global.volume= globals.get("volume")
		Global.volume_music= globals.get("volume_music")
		Global.volume_effect= globals.get("volume_effect")
		return true
	else:
		return false
func _ready() -> void:
	load_globals()






	
