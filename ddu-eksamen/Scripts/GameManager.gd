extends Node

# Setting Up Dictionaries, Lists and Variables -----------------------------------------------------------------------
var data: Dictionary = {}
var colonist_dict: Dictionary = {}         
var workers_dict: Dictionary = {}
var assignment_dict: Dictionary = {}
var trait_dict: Dictionary = {}
var name_array: Array = []
var workplaces: Dictionary = {
	"food": "farm",
	"plant_matter": "plants",
	"minerals" : "mine", 
	"research_points": "research_lab", 
}

var colony_start_amount = 6                # the amount of colonists that starts in the colony
var total_trait_amount = 6                 # the amount of traits each colonist has
var current_tick = 0                       # sets current_tick to zero
signal value_changed
const SAVE_FILE = "user://database.json"


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
		if random != 0:
			temp_trait_array.append(random)
			duplicate_genetic_array.erase(random)
		elif random == 0:
			temp_trait_array.append(random)
	return temp_trait_array

# change so that you can generate multiple neutral traits (ID 000)
func get_new_colony(colony_population):
	for colonist in colony_population:
		var colonist_name = generate_colonist_name()
		var trait_array: Array = generate_starter_trait_array()
		colonist_dict[colonist_name] = trait_array
		workers_dict[colonist_name] = "Unemployed"
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
	value_changed.connect(save_game)

# Save system---------------------------------------------------------------------------
func save_game():
	data = { #updates a dictonary with new values for all resources. in the future this will a
#also update with the completed endings and other factors.
		"food" = Global.food,
		"plant_matter" = Global.plant_matter,
		"minerals" = Global.minerals,
		"research_points" = Global.research_points
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
# Tick System --------------------------------------------------------------------------------------------------

func _on_tick_timer_timeout() -> void:
	current_tick += 1
	print(current_tick)
	
# Resource functions-------------------------------------------------------------------------------------------------
func worker_productivity(worker):
	var traits = colonist_dict[colonist_dict.keys()[worker]]
	var temp_prod = 1
	for i in traits:
		temp_prod*=trait_dict[i]["productivity_mod"]
	return temp_prod

func workplace_productivity(Workplace):
	var temp_prod = 0
	for worker in range(len(workers_dict)):
		if workers_dict[workers_dict.keys()[worker]] == Workplace:
			temp_prod+=float(worker_productivity(worker))
	return temp_prod

func resource_tick():
	var possible_resources = ["food", "minerals", "plant_matter", "research_points"]
	for resource in possible_resources:
		var productivity = workplace_productivity(workplaces[resource])
		get_new_resource(resource, productivity)
	resource_consumption_tick()
	#need to be looked through

func resource_consumption_tick(modifier = null):
	var food_consumption_tick_value: float = 1.0
	var num_of_colonist = len(colonist_dict) #finds the number of colonist
	if modifier != null:
		var food_consumption = num_of_colonist * modifier * food_consumption_tick_value
		resource_consumption(Global.food, food_consumption)
		return #calculates the food consumption if a modifier is passed into the funciton
	else:
		var food_consumption = num_of_colonist * food_consumption_tick_value
		resource_consumption(Global.food, food_consumption)
		return #calculates the food consumption if a modifier is not passed into the funciton
	
func resource_consumption(type, amount):
	#helper function to subtract the amount of resources used for a specific action
	if type < amount:
		return false
	type -= amount
	return true

func get_new_resource(resource: String, productivity: int):
	var prod_modifier
	match resource:
		"food":
			prod_modifier = 1.0
		"minerals":
			prod_modifier = 1.0
		"plant_matter":
			prod_modifier = 1.0
		"research_points":
			prod_modifier = 0.1
		_:
			return 0
	var base_yield: float = productivity *  prod_modifier
	return base_yield
