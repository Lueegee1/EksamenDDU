extends Node

# Setting Up Dictionaries, Lists and Variables -----------------------------------------------------------------------
var data: Dictionary = {}
var colonist_dict: Dictionary = {}         
var workers_dict: Dictionary = {}
var happiness_dict: Dictionary = {}
var trait_dict: Dictionary = {}
var name_array: Array = []
var researches: Dictionary = {}
var workplaces: Dictionary = {
	"food": "farm",
	"plant_matter": "plants",
	"minerals" : "mine", 
	"research_points": "research_lab", 
}
var base_happiness = 50
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

func load_researches_from_json(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var _result = json.parse(json_text)
	var temp_dict = json.data["research"]
	for key in temp_dict.keys():
		researches[int(key)] = temp_dict[key]
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
		happiness_dict[colonist_name] = {"happiness": base_happiness, "sick" : false, "grieving": false, "homeless" : false, "surgery": false, "blood_on_hands": false}
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
	load_researches_from_json("res://data/research.json")
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
	happiness_tick()
	print(average_happiness())
# Resource functions-----------------------------------------------------------------------------------------------

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

# Research funtions

func meet_research_requirements(index: int):
	if researches[index]["researched"]==1:
		return false
	for i in researches[index]["requirements"]:
		if researches[int(i)]["researched"] == 0:
			return false	
	return true

func can_afford_research(index: int):
	var price_array = researches[index]["cost"]
	if Global.research_points< price_array[0]:
		return false
	if Global.plant_matter < price_array[1]:
		return false
	if Global.minerals < price_array[2]:
		return false
	if Global.food < price_array [3]:
		return false
	return true

func research(index: int):
	if meet_research_requirements(index) and can_afford_research(index):
		var price_index = researches[index]["cost"]
		Global.research_points -=price_index[0]
		Global.plant_matter -= price_index[1]
		Global.minerals -= price_index[2]
		Global.food -= price_index[3]
		researches[index]["researched"]=1
		print(researches[index]["name"] + " has been researched")
	else:
		print("Couldnt afford research")

# Breeding

func breed_colonist(parent1: String, parent2: String):
	print("start breeding")
	var traits1 = colonist_dict[parent1].duplicate()
	var traits2 = colonist_dict[parent2].duplicate()
	print("the parents names are: ", parent1," and ", parent2)
	print("the the childs parents traits are:", traits1, " and ", traits2)
	var child_traits:Array = []
	traits1.shuffle()
	traits1 = traits1.slice(0, traits1.size() / 2)
	traits2.shuffle()
	traits2 = traits2.slice(0, traits2.size() / 2)
	child_traits.append_array(traits1)
	child_traits.append_array(traits2)
	print("the new childs traits are: ", child_traits)
	var child_name = generate_colonist_name()
	if child_name == parent1 or child_name == parent2:
		child_name = "Jr. " + child_name
	print("childs name is: ", child_name)
	colonist_dict[child_name] = child_traits
	workers_dict[child_name] = "Unemployed"
	happiness_dict[child_name] = base_happiness
	

# Backend assignment

func assign_colonist(colonist_name: String, workplace: String) -> bool:
	if colonist_name not in colonist_dict:
		return false
	workers_dict[colonist_name] = workplace
	return true

# Happiness calcs

func happiness_tick():
	var happy_base = 0 
	happy_base += Global.decorations
	if Global.food < 0:
		happy_base-=10
	else:
		happy_base+=15
	for colonist in happiness_dict:
		if happiness_dict[colonist]["sick"] == true:
			happy_base-=10
		if happiness_dict[colonist]["homeless"]:
			happy_base-=10
		if happiness_dict[colonist]["surgery"]:
			happy_base-=10
		if happiness_dict[colonist]["blood_on_hands"]:
			happy_base-=10
		var happy_modifier = 1
		for mod in colonist_dict[colonist]:
			happy_modifier*=trait_dict[mod]["happiness_mod"]
		var happiness = (base_happiness + happy_base) * happy_modifier
		happiness = clamp(happiness, 0, 100)
		happiness_dict[colonist]["happiness"] = happiness

func average_happiness():
	var avg_happy = 0
	for colonist in happiness_dict:
		avg_happy += happiness_dict[colonist]["happiness"]
	avg_happy/=len(happiness_dict)
	return(avg_happy)
