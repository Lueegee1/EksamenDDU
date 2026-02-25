extends Node

var colony_start_amount = 6
var colonist_dict: Dictionary = {}
var assignment_dict: Dictionary = {}
var name_array: Array = []
var trait_dict = {
	000:{"name":"Neutral","productivity_mod":1,"happiness_mod":1,"sickness_chance":1},
	001:{"name":"Sanguine","productivity_mod":1,"happiness_mod":1.1,"sickness_chance":1},
	002:{"name":"Pessimistic","productivity_mod":1,"happiness_mod":0.9,"sickness_chance":1},
	003:{"name":"Effective","productivity_mod":1.2,"happiness_mod":1,"sickness_chance":1},
	004:{"name":"Lazy","productivity_mod":0.8,"happiness_mod":1,"sickness_chance":1},
	005:{"name":"Healthy","productivity_mod":1,"happiness_mod":1,"sickness_chance":0.5},
	006:{"name":"Sickly","productivity_mod":1,"happiness_mod":1,"sickness_chance":2},
}
var genetics_array = trait_dict.keys()

var current_tick = 0

# Loading Data from JSON Files ----------------------------------------------------------------------------------

func load_names_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var _result = json.parse(json_text)
	name_array = json.data["names"]

# Game Setup ----------------------------------------------------------------------------------

func generate_colonist_name() -> String:
	if name_array.is_empty():
		return "ERROR#NANINF/DIV0"
	var generated_name = name_array.pick_random()
# rerolls name if duplicate
	while colonist_dict.has(generated_name):
		generated_name = name_array.pick_random()
	return generated_name

func generate_starter_trait_array():
	var temp_trait_array = []
	var duplicate_genetic_array = genetics_array.duplicate()
	for number in 6:
		var random = duplicate_genetic_array.pick_random()
		temp_trait_array.append(random)
		duplicate_genetic_array.erase(random)
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
	get_new_colony(colony_start_amount)

# Tick System --------------------------------------------------------------------------------------------------

func _on_tick_timer_timeout() -> void:
	current_tick += 1
	print(current_tick)
