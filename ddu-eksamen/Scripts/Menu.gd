extends Node2D

const SAVE_FILE = "user://database.json"
var wins
const settings_scene= preload("res://Scenes/Settings.tscn")
@onready var click = $ButtonClick
func Click():
	click.play()

func _on_button_1_pressed() -> void:
	Click()
	#Global.SceneChanger.load_scene("IntroCutScene")
	Global.load_game = true
	Global.SceneChanger.load_scene("Game")
	

func _on_button_2_pressed() -> void:
	Click()
	Global.load_game = false
	Global.SceneChanger.load_scene("IntroCutScene")
	pass # Replace with function body.
	
	
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
func _ready() -> void:
	load_wins()
	$MenuUI/Label.text = str(wins)

var range_mod=7.66
func _process(delta: float) -> void:
	click.volume_db = -60 + range_mod*log(Global.volume) + range_mod*log(Global.volume_effect)
	pass


func _on_button_8_pressed() -> void:
	Click()
	var menu = settings_scene.instantiate()
		#get_tree().get_root().find_child("SettingsLayer", true, false).add_child(menu)
	self.add_child(menu)
	menu.z_index = 100
	menu.position = Vector2(0,0)
	menu.visible = true
