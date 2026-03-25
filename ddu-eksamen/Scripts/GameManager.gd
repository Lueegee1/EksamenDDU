extends Node

# Setting Up Dictionaries, Lists and Variables -----------------------------------------------------------------------

var food_security_constant: float = 1.0
var data: Dictionary = {}
var colonist_dict: Dictionary = {}         
var workers_dict: Dictionary = {}
var happiness_dict: Dictionary = {}
var trait_dict: Dictionary = {}
var housing_dictionary: Dictionary = {
	"not_built" :
		{
			"capacity" : 0,
			"assigned" : []
		}
}
var movement_and_sprite_dictionary: Dictionary = {}
var workstation_dictionary: Dictionary = {}
var name_array: Array = []
var working_colonist:Array = []
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
var research_prod_modifier:float = 0.1
var plant_prod_modifier:float = 1.0
var food_prod_modifier:float = 1.0
var minerals_prod_modifier:float = 1.0
var building_positions:Dictionary = {
	"farm": [120,950],
	"forest": [400,100],
	"mine": [1300,200],
	"house1": [840,125],
	"house2": [600,370]
	
}
signal value_changed
const SAVE_FILE = "user://database.json"
var is_starving = false

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

func generate_colonist_name() -> String: # generates the colonists name
	if name_array.is_empty():
		return "ERROR#NANINF/DIV0" # good luck getting this name lol
	var generated_name = name_array.pick_random()
# rerolls name if duplicate
	while colonist_dict.has(generated_name):
		generated_name = name_array.pick_random()
	return generated_name

func generate_starter_trait_array(): #generates the starter trait array for the colonist
	var temp_trait_array = []
	var duplicate_genetic_array = trait_dict.keys()
	for number in range(total_trait_amount):
		var random = duplicate_genetic_array.pick_random()
		if random != 0:
			temp_trait_array.append(random)
			duplicate_genetic_array.erase(random)
		elif random == 0:
			temp_trait_array.append(random)
	return temp_trait_array

# change so that you can generate multiple neutral traits (ID 000)
func get_new_colony(colony_population):
	for colonist in colony_population: # for each colonist in the colony population 
		var colonist_name = generate_colonist_name() #get a name
		var trait_array: Array = generate_starter_trait_array() # the trait array
		colonist_dict[colonist_name] = trait_array #adds them to the colonist dict
		workers_dict[colonist_name] = "unemployed" #adds them as unemployed to the workers dict
		happiness_dict[colonist_name] = {"happiness": base_happiness, "sick" : false, "grieving": false, "homeless" : false, "surgery": false, "blood_on_hands": false}
		movement_and_sprite_dictionary[colonist_name] = {
			"position": [randf_range(0, 1920), randf_range(0, 1080)],
			"target": Vector2.ZERO,
			"state": "idle",  # idle | going_to_work | going_home | wandering
			"speed": 5.0     # pixels per second
		}
# Next lines of code are purely for printing to console
		print("Created colonist # ", colonist +1, " Their name is ", colonist_name)
		var traits_list_temp: Array = []
		for i in trait_array:
			traits_list_temp.append(trait_dict[i]["name"])
		print(colonist_name, " traits: ", traits_list_temp)
		value_changed.emit()

# On Startup Function calls --------------------------------------------------------------------------------------------------

func _ready():
	Global.GameManager = self
	value_changed.connect(save_game)
	load_names_from_json("res://data/names.json")
	load_traits_from_json("res://data/traits.json")
	load_researches_from_json("res://data/research.json")
	# the below two lines should be turned into real lines when we want to test the save sytem
	#if not load_game():
	get_new_colony(colony_start_amount)

#colonist pathfinding and location functions:
func get_workstation_position(workplace: String) -> Array:
	return building_positions.get(workplace, [0.0,0.0])

func get_home_position(colonist: String) -> Array:
	for house_id in housing_dictionary:
		if "assigned" in housing_dictionary[house_id] and colonist in housing_dictionary[house_id]["assigned"]:
			return building_positions.get(house_id, [0.0,0.0])
	return [0.0,0.0]
		
func remove_working_colonist(colonist_name):
	working_colonist.erase(colonist_name)
	

func colonist_work_day_addition(colonist_name):
	working_colonist.append(colonist_name)
	await get_tree().create_timer(30.0)
	remove_working_colonist(colonist_name)
	#unload(colonist_name)
	#set timer until the colonist workday is over
	#add dicitonary with the working colonist

func colonist_move(delta: float) -> void:
	for colonist in colonist_dict:
		var mov = movement_and_sprite_dictionary[colonist]
		var assignment = workers_dict.get(colonist, "unemployed")
		match mov["state"]:
			"idle":# if the colonist is idle then set them to wandering if unemployed or to going to work
				if assignment == "unemployed":
					mov["state"] = "wandering"
				else:
					mov["state"] = "going_to_work"
			
			"going_to_work": #if they are going to work then move them towards their workstation
				#if they arrived then change it so theyre going home
				var target = get_workstation_position(assignment)
				mov["target"] = target
				if move_toward_target(mov, delta):
					mov["state"] = "going_home"
			
			"going_home": #if they're going home then go towards home or alse 
				var target = get_home_position(colonist)
				mov["target"] = target
				if move_toward_target(mov, delta):
					mov["state"] = "going_to_work"
				# no home → wander
				if target == null:
					mov["state"] = "wandering"
				elif move_toward_target(mov, delta):
					mov["state"] = "going_to_work"
			
			"wandering":
				var pos = Vector2(mov["position"][0], mov["position"][1])
				var target = Vector2(mov["target"][0], mov["target"][1])
				if pos.distance_to(target) < 10.0:
					mov["target"] = [randf_range(50, 1870), randf_range(50, 1030)]
				move_toward_target(mov, delta)
				# re-check if they got assigned a job
				if assignment != "unemployed":
					mov["state"] = "idle"
	value_changed.emit()


func move_toward_target(mov: Dictionary, delta: float) -> bool:
	var pos = Vector2(mov["position"][0], mov["position"][1])
	var target = Vector2(mov["target"][0], mov["target"][1])
	var direction = target - pos
	if direction.length() < 5.0:
		return true  # if length less than 5.0 then the colonist has arrived
		#here we will call the colonist_work_day function
	pos += direction.normalized() * mov["speed"] * delta
	mov["position"] = [pos.x, pos.y]
	return false
#0,0 til 1920*1080 i hd	

# Save system---------------------------------------------------------------------------
#saves the game and return a true/false if the saving was succesfull
func save_game() -> bool:
	#defines data to hold all the variables we need to store
	data = { #saves resources and decorations added
		"resources": {
			"food": Global.food,
			"plant_matter": Global.plant_matter,
			"minerals": Global.minerals,
			"research_points": Global.research_points,
			"decorations": Global.decorations
			
		}, #saves current tick and is_starving
		"simulation": {
			"current_tick": current_tick,
			"is_starving": is_starving
		},# saves all relevant dictionaries to the colony
		"colony": {
			"colonist_dict": colonist_dict,
			"workers_dict": workers_dict,
			"happiness_dict": happiness_dict,
			"housing_dictionary": housing_dictionary,
			"workstation_dictionary": workstation_dictionary,
			 "movement_and_sprite_dictionary": movement_and_sprite_dictionary
		},
		"research": { #saves research
			"researches": researches
		},
		"modifiers": {
			"research": research_prod_modifier,
			"plant": plant_prod_modifier,
			"food": food_prod_modifier,
			"minerals": minerals_prod_modifier
		}
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null: #creates a file variable that holds the opened save_file and checks if it was succesfully opened
		return false

	if file.store_string(JSON.stringify(data)) != true: #stores the json stringified version of data and if it was saved
		#succesfully it returns true else it returns false
		file.close()
		return false
	file.close()
	return true
	
func load_game() -> bool:
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
	if saved_data.has("resources"): #checks if saved_data has all the resource variables and loads thjem into game
		var resources = saved_data["resources"]
		Global.food = resources.get("food", 0)
		Global.plant_matter = resources.get("plant_matter", 0)
		Global.minerals = resources.get("minerals", 0)
		Global.research_points = resources.get("research_points", 0)
		Global.decorations = resources.get("decorations", 0)
	#checks if saved_data has the modifier variables and loads them into the game
	if saved_data.has("modifiers"):
		var modifiers = saved_data["modifiers"]
		research_prod_modifier = modifiers.get("research", 0.1)
		plant_prod_modifier = modifiers.get("plant", 1.0)
		food_prod_modifier = modifiers.get("food", 1.0)
		minerals_prod_modifier = modifiers.get("minerals", 1.0)
	# tick and hungry yes/no 
	if saved_data.has("simulation"): #checks if saved data has tick and is_starving saved
		var simulation = saved_data["simulation"]
		current_tick = simulation.get("current_tick", 0)
		is_starving = simulation.get("is_starving", false)

	# Colony 
	if saved_data.has("colony"):
		var colony = saved_data["colony"]
		colonist_dict = colony.get("colonist_dict", {})
		workers_dict = colony.get("workers_dict", {})
		happiness_dict = colony.get("happiness_dict", {})
		housing_dictionary = colony.get("housing_dictionary", {})
		workstation_dictionary = colony.get("workstation_dictionary", {})
		movement_and_sprite_dictionary = colony.get("movement_and_sprite_dictionary", {}) 

	# Research/ not really sure this works but fuck it we ball
	if saved_data.has("research"):
		var research_data = saved_data["research"]
		researches = research_data.get("researches", researches)
	return true

# Tick System --------------------------------------------------------------------------------------------------

func _on_tick_timer_timeout() -> void:
	current_tick += 1
	happiness_tick()
	Global.average_happiness = average_happiness()

# Resource functions-----------------------------------------------------------------------------------------------

func worker_productivity(worker): #calculates the individual workers productivity
	var traits = colonist_dict[colonist_dict.keys()[worker]]
	var temp_prod = 1
	for i in traits:
		temp_prod*=trait_dict[i]["productivity_mod"]
	return temp_prod

func workplace_productivity(Workplace): #calculates the workplaces productivity
	var temp_prod = 0
	for worker in range(len(workers_dict)):
		if workers_dict[workers_dict.keys()[worker]] == Workplace:
			temp_prod+=float(worker_productivity(worker))
	return temp_prod

func resource_tick(): #tick that handles resource consumption and getting the new resources
	var possible_resources = ["food", "minerals", "plant_matter", "research_points"]
	for resource in possible_resources:
		var productivity = workplace_productivity(workplaces[resource])
		Global.set(resource, Global.get(resource) + get_new_resource(resource, productivity))
	resource_consumption_tick()
	value_changed.emit()
	#need to be looked through

func resource_consumption_tick(modifier = null): #calculates resource consumption and 
	#checks if the colony is starving
	var food_consumption_tick_value: float = 1.0
	var num_of_colonist = len(colonist_dict) #finds the number of colonist
	if modifier != null:
		var food_consumption = num_of_colonist * modifier * food_consumption_tick_value
		if resource_consumption("food", food_consumption):
			return
		else:
			is_starving = true
			return
	else:
		var food_consumption = num_of_colonist * food_consumption_tick_value
		if resource_consumption("food", food_consumption):
			return 
		else: 
			is_starving = true
			return 
	

	#helper function to subtract the amount of resources used for a specific action
func resource_consumption(resource_name: String, amount: float) -> bool:
	var current = Global.get(resource_name)
	if current < amount:
		return false
	Global.set(resource_name, current - amount)
	value_changed.connect(save_game)
	return true

func get_new_resource(resource: String, productivity: int):
	var prod_modifier #gets the new resource and returns how much of it is produced
	match resource:
		"food":
			prod_modifier = food_prod_modifier
		"minerals":
			prod_modifier = minerals_prod_modifier
		"plant_matter":
			prod_modifier = plant_prod_modifier
		"research_points":
			prod_modifier = research_prod_modifier
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
		apply_research(index)
		value_changed.emit()
	else:
		print("Couldnt afford research")

# Breeding
func breeding() ->bool: #functions that calculates if two colonist are gonna breed together and returns false if somebody didnt and somebody did
	for house in housing_dictionary:
		var assigned = housing_dictionary[house]["assigned"]
		if assigned.size() >= 2:
			if Global.food > len(colonist_dict) * food_security_constant:
				if randf() < 1.0:
					breed_colonist(assigned[0], assigned[1])
					value_changed.emit()
					return true
	return false

func breed_colonist(parent1: String, parent2: String): #helper function to breed to colonist
	var traits1 = colonist_dict[parent1].duplicate()
	var traits2 = colonist_dict[parent2].duplicate()
	var child_traits:Array = []
	traits1.shuffle()
	traits1 = traits1.slice(0, traits1.size() / 2)
	traits2.shuffle()
	traits2 = traits2.slice(0, traits2.size() / 2)
	child_traits.append_array(traits1)
	child_traits.append_array(traits2)
	var child_name = generate_colonist_name()
	if child_name == parent1 or child_name == parent2:
		child_name = "Jr. " + child_name
	colonist_dict[child_name] = child_traits
	workers_dict[child_name] = "unemployed"
	happiness_dict[child_name] = {
		"happiness": base_happiness,
		"sick": false,
		"grieving": false,
		"homeless": false,
		"surgery": false,
		"blood_on_hands": false
}
	movement_and_sprite_dictionary[child_name] = {
			"position": [randf_range(0, 1920), randf_range(0, 1080)],
			"target": [0.0,0.0],
			"state": "idle", 
			"speed": 5.0     
		}
	

# Backend assignment
func assign_colonist_to_house(name, house): #helper funciton to assign a specific colonist to a specific house
	if len(housing_dictionary[house]["assigned"]) < housing_dictionary[house]["capacity"] and name not in housing_dictionary[house]["assigned"]:
		housing_dictionary[house]["assigned"].append(name)
		value_changed.emit()
		return true
	return false #returns false if the assignment was unsuccesfull
		
func assign_colonist_to_workplace(colonist_name: String, workplace: String) -> bool: #helper function to assign a specific colonist to a specific workplace
	if colonist_name not in colonist_dict:
		return false
	workers_dict[colonist_name] = workplace
	value_changed.emit()
	return true

# Backend building

func build_new_building(type):
	match type:
		"house":
			var id = "house" + str(housing_dictionary.size() + 1)
			housing_dictionary[id] = {
				"capacity": 1,
				"assigned": []
			}
			resource_consumption("minerals", 10)
			resource_consumption("plant_matter", 10)
		"food", "research", "mine", "plant_station":
			workstation_dictionary[type] = {
				"assigned": []
			}
			resource_consumption("plant_matter", 10)
	value_changed.emit()

func upgrade_building(building) -> bool:
	for house in housing_dictionary:
		if house == building:
			if housing_dictionary[house]["capacity"] == 1:
				if researches[9]["researched"] == 1:
					housing_dictionary[house]["capacity"] = 2
					value_changed.emit()
					return true
	return false
	
	
# apply research buff
func apply_research(index):
	match index:

		# RESEARCH
		1:
			research_prod_modifier += 0.05

		10:
			research_prod_modifier += 0.20

		14:
			research_prod_modifier += 0.25


		# PLANTS
		6:
			plant_prod_modifier *= 1.25

		18:
			plant_prod_modifier *= 1.40


		# FOOD
		3:
			food_prod_modifier *= 1.15

		5:
			food_prod_modifier *= 1.25

		13:
			food_prod_modifier *= 1.30

		21:
			food_prod_modifier *= 1.50


		# MINERALS
		2:
			minerals_prod_modifier *= 1.10

		8:
			minerals_prod_modifier *= 1.25

		16:
			minerals_prod_modifier *= 1.45

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
			happy_modifier*=trait_dict[int(mod)]["happiness_mod"]
		var happiness = (base_happiness + happy_base) * happy_modifier
		happiness = clamp(happiness, 0, 100)
		happiness_dict[colonist]["happiness"] = happiness
		value_changed.emit()

func average_happiness():
	var avg_happy = 0
	for colonist in happiness_dict:
		avg_happy += happiness_dict[colonist]["happiness"]
	if len(happiness_dict) == 0:
		return 0
	avg_happy/=len(happiness_dict)
	return(avg_happy)
