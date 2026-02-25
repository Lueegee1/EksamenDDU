extends Node

# Setting Up Dictionaries, Lists and Variables -----------------------------------------------------------------------

var colonist_dict: Dictionary = {}         
var assignment_dict: Dictionary = {}
var trait_dict: Dictionary = {}
var name_array: Array = []

var colony_start_amount = 6                # the amount of colonists that starts in the colony
var total_trait_amount = 6                 # the amount of traits each colonist has
var current_tick = 0                       # sets current_tick to zero

# Loading Data from JSON Files ----------------------------------------------------------------------------------

func load_names_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var _result = json.parse(json_text)
	name_array = json.data["names"]

func load_traits_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var _result = json.parse(json_text)
	var temp_dict = json.data["traits"]
	for key in temp_dict.keys():
		trait_dict[int(key)] = temp_dict[key]

# Game Setup ----------------------------------------------------------------------------------

func generate_colonist_name() -> String:
	if name_array.is_empty():
		return "ERROR#NANINF/DIV0" # good luck getting this name lol
	var generated_name = name_array.pick_random()
# rerolls name if duplicate
	while colonist_dict.has(generated_name):
		generated_name = name_array.pick_random()
	return generated_name

func generate_starter_trait_array():
	var temp_trait_array = []
	var duplicate_genetic_array = trait_dict.keys()
	for number in total_trait_amount:
		var random = duplicate_genetic_array.pick_random()
		if random != 000:
			temp_trait_array.append(random)
			duplicate_genetic_array.erase(random)
		elif random == 000:
			temp_trait_array.append(random)
	return temp_trait_array

# change so that you can generate multiple neutral traits (ID 000)
func get_new_colony(colony_population):
	for colonist in colony_population:
		var colonist_name = generate_colonist_name()
		var trait_array: Array = generate_starter_trait_array()
		colonist_dict[colonist_name] = trait_array
# Next lines of code are purely for printing to console
		print("Created colonist # ", colonist +1, " Their name is ", colonist_name)
		var traits_list_temp: Array = []
		for i in trait_array:
			traits_list_temp.append(trait_dict[i]["name"])
		print(colonist_name, " traits: ", traits_list_temp)

# On Startup Function calls --------------------------------------------------------------------------------------------------

func _ready():
	load_names_from_json("res://data/names.json")
	load_traits_from_json("res://data/traits.json")
	get_new_colony(colony_start_amount)

# Tick System --------------------------------------------------------------------------------------------------

func _on_tick_timer_timeout() -> void:
	current_tick += 1
	print(current_tick)
