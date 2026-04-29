extends Node

# Setting Up Dictionaries, Lists and Variables -----------------------------------------------------------------------
var colonist_instances: Dictionary = {}
@onready var colonist_container = $UI/Colonistholder
const colonist_body_scene = preload("res://Scenes/Colonists.tscn")
var food_security_constant: float = 25.0
var data: Dictionary = {}
var colonist_dict: Dictionary = {}         
var workers_dict: Dictionary = {}
var happiness_dict: Dictionary = {}
var possible_colonist_sprites = ["res://Assets/temp files/ColonistsSprites1.png", "res://Assets/temp files/ColonistsSprites2.png", "res://Assets/temp files/ColonistsSprites3.png", "res://Assets/temp files/ColonistsSprites4.png","res://Assets/temp files/ColonistsSprites5.png", "res://Assets/temp files/ColonistsSprites6.png", "res://Assets/temp files/ColonistsSprites7.png", "res://Assets/temp files/ColonistsSprites8.png", "res://Assets/temp files/ColonistsSprites9.png", "res://Assets/temp files/ColonistsSprites10.png"]
var trait_dict: Dictionary = {}
var sprite_dict = {}
var position_dict = {}
var housing_dictionary: Dictionary = {
	"not_built" :
		{
			"capacity" : 100,
			"assigned" : []
		}
}
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
var colony_start_amount = 4                # the amount of colonists that starts in the colony
var total_trait_amount = 6                 # the amount of traits each colonist has
var current_tick = 0                       # sets current_tick to zero
var research_prod_modifier:float = 0.1
var plant_prod_modifier:float = 1.0
var food_prod_modifier:float = 1.0
var minerals_prod_modifier:float = 1.0
var house_price = [100,100]
var house_upgrade1_price = [150,200]
var workday_lenght = 60
var current_positions = []
#Ending stuff
var flag_killed = false
var leader: String
var game_won = false
var game_loaded = false
var wins = []

signal value_changed
const SAVE_FILE = "user://database.json"
var is_starving = false
var building_positions: Dictionary = {}
var building_markers_node: Node  
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
#win and lose condition checkers

func game_condition_tick():
	if Global.average_happiness == 100:
		win_game("genes")
	lose_game()
	
func win_game(flag):
	if game_won:
		return
	if flag == "pod":
		print("Game Won: Pod")
	if flag == "religion":
		print("Game Won: Religion")
	if flag == "genes" and flag_killed:
		print("Game Won: Euginics")
		flag = "Euginics"
	if flag == "genes" and not flag_killed:
		print("Game Won: Luck")
		flag = "Luck"
	if flag not in wins:
		wins.append(flag)
	game_won = true
	
func lose_game():
	if Global.average_happiness == 5 or colonist_dict.size() == 0:
		print("Game lost")



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
		happiness_dict[colonist_name] = {"happiness": base_happiness, "sick" : false, "grieving_1": false, "homeless" : false, "surgery": false, "grieving_2": false, "starving": false}
		setup_colonist_body(colonist_name, get_colonist_sprite(), null)
# Next lines of code are purely for printing to console
		print("Created colonist # ", colonist +1, " Their name is ", colonist_name)
		var traits_list_temp: Array = []
		for i in trait_array:
			traits_list_temp.append(trait_dict[i]["name"])
		print(colonist_name, " traits: ", traits_list_temp)
		update_position()
		update_sprite()
		value_changed.emit()

# On Startup Function calls --------------------------------------------------------------------------------------------------
func setup_colonist_body(colonist_name: String, sprite, position) -> void:
	print("AAAAAAAAAAAAAAAAAAAAAAAA")
	var body = colonist_body_scene.instantiate()
	colonist_container.add_child(body)
	if position == null:
		for marker in $UI/Background/Ground/Buldingmarkers.get_children():
			building_positions[marker.name.to_lower()] = marker.global_position
		var keys = building_positions.keys()
		var filtered = keys.filter(func(x): return x not in current_positions)
		print("available positions: ", keys)
		print("current_positions: ", current_positions)
		var pos = building_positions[filtered.pick_random()]
		current_positions.append(pos)
		body.setup(sprite, colonist_name, pos)
		colonist_instances[colonist_name] = body
		print(str(colonist_instances[colonist_name]))
	else:
		body.setup(sprite, colonist_name, position)
		colonist_instances[colonist_name] = body

	
func get_colonist_sprite():
	var sprite = possible_colonist_sprites.pick_random()
	possible_colonist_sprites.erase(sprite)
	return sprite
		
func _load_building_positions() -> void:
	for marker in building_markers_node.get_children():
		building_positions[marker.name.to_lower()] = marker.global_position


func _ready():
	Global.GameManager = self
	value_changed.connect(save_game)
	load_names_from_json("res://data/names.json")
	load_traits_from_json("res://data/traits.json")
	load_researches_from_json("res://data/research.json")
	# the below two lines should be turned into real lines when we want to test the save sytem
	building_markers_node = get_tree().get_root().find_child("Buldingmarkers", true, false)
	_load_building_positions()
	if FileAccess.file_exists(SAVE_FILE) and Global.load_game: #checker om save filen eksiterer og om den skal loade
		load_game()
	else:
		new_game()
		get_new_colony(colony_start_amount)
	game_loaded = true

#colonist pathfinding and location functions:
func get_workstation_position(workplace: String) -> Vector2:
	return building_positions.get(workplace, Vector2.ZERO)

func get_home_position(colonist: String):
	for house_id in housing_dictionary:
		if "assigned" in housing_dictionary[house_id] and colonist in housing_dictionary[house_id]["assigned"]:
			return building_positions.get(house_id, Vector2.ZERO)
	return null
		


# Save system---------------------------------------------------------------------------
#saves the game and return a true/false if the saving was succesfull
func save_game() -> bool:
	update_sprite()
	update_position()
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
			"colonist_instances": colonist_instances,
			"sprite_dict": sprite_dict,
			"position_dict": position_dict,
		},
		"research": { #saves research
			"researches": researches
		},
		"modifiers": {
			"research": research_prod_modifier,
			"plant": plant_prod_modifier,
			"food": food_prod_modifier,
			"minerals": minerals_prod_modifier
		},
		"achieved_wins": {
			"wins": wins
		},
		"globals": {
			"tick_interval": Global.tick_interval,
			"volume": Global.volume,
			"volume_music": Global.volume_music,
			"volume_effect": Global.volume_effect,
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
	
	#JSON files have to be loaded to setup game
	load_names_from_json("res://data/names.json")
	load_traits_from_json("res://data/traits.json")
	load_researches_from_json("res://data/research.json")
	
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
		var required_keys = ["colonist_dict", "workers_dict", "happiness_dict", 
							 "housing_dictionary", "workstation_dictionary", 
							 "colonist_instances", "sprite_dict", "position_dict"]
		if not required_keys.all(func(key): return colony.has(key)):
			return false
		colonist_dict = colony.get("colonist_dict", {})
		workers_dict = colony.get("workers_dict", {})
		happiness_dict = colony.get("happiness_dict", {})
		housing_dictionary = colony.get("housing_dictionary", {})
		workstation_dictionary = colony.get("workstation_dictionary", {})
		colonist_instances = colony.get("colonist_instances", {})
		sprite_dict = colony.get("sprite_dict", {})
		position_dict = colony.get("position_dict", {})
		for colonist_name in colonist_dict:
			#print(str(sprite_dict) + str(position_dict))
			setup_colonist_body(colonist_name, sprite_dict[colonist_name], string_to_vector2(position_dict[colonist_name]))
		for key in trait_dict:
			trait_dict[int(key)] = trait_dict[key]
			
		update_sprite()
	else:
		return false
	if saved_data.has("achieved_wins"):
		var achieved_wins = saved_data["achieved_wins"]
		wins = achieved_wins.get("wins")
	if saved_data.has("globals"):
		var globals= saved_data["globals"]
		Global.tick_interval= globals.get("tick_interval")
		Global.volume= globals.get("volume")
		Global.volume_music= globals.get("volume_music")
		Global.volume_effect= globals.get("volume_effect")
		
	game_loaded = true
	

	# Research/ not really sure this works but fuck it we ball
	if saved_data.has("research"):
		var research_data = saved_data["research"]
		researches = research_data.get("researches", researches)
	var temp = {}
	for key in researches:
		temp[int(key)] = researches[key]
	researches = temp
	
	for i in researches:
		if researches[i]["researched"] == 1:
			apply_research(i)
	for i in colonist_dict:
		grieving(i)
	return true
	
func new_game() -> void:
	var has_save = true
	if not FileAccess.file_exists(SAVE_FILE): #checker om save filen eksiterer
		has_save = false
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ) #opens the file and saves it in read mode as variable file and checks if opening
#it was succesfull
	var save_text
	if file == null:
		has_save = false
		return
	save_text = file.get_as_text()
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
			var preserved_wins = achieved_wins.get("wins")
			wins = preserved_wins
		if FileAccess.file_exists(SAVE_FILE):
			DirAccess.remove_absolute(SAVE_FILE)
			
	
func string_to_vector2(s: String) -> Vector2:
	s = s.strip_edges().trim_prefix("(").trim_suffix(")")
	var parts = s.split(",")
	return Vector2(float(parts[0]), float(parts[1]))
# Tick System --------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if current_tick > 1:
		var to_erase = []
		for i in colonist_instances:
			if not is_instance_valid(colonist_instances[i]):
				to_erase.append(i)
		for i in to_erase:
			colonist_instances.erase(i)
	pass

func _on_tick_timer_timeout() -> void:
	$TickTimer.wait_time = 1/Global.tick_interval
	if int(current_tick)%10 == 0:
		save_game()
	current_tick += 1
	if not game_won:
		for colonist in colonist_dict:
			if colonist not in colonist_instances:
				return
			if not is_instance_valid(colonist_instances[colonist]):
				return
		happiness_tick()
		resource_tick()
		breeding()
		sick_tick()
		Global.average_happiness = average_happiness()
		game_condition_tick()


# Resource functions-----------------------------------------------------------------------------------------------

func worker_productivity(worker): #calculates the individual workers productivity
	var traits = colonist_dict[colonist_dict.keys()[worker]]
	var temp_prod = 1
	for i in traits:
		temp_prod*=trait_dict[int(i)]["productivity_mod"]
	return temp_prod

func workplace_productivity(Workplace): #calculates the workplaces productivity
	var temp_prod = 0
	for worker in range(len(workers_dict)):
		
		if colonist_instances[workers_dict.keys()[worker]].state=="working":
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
	if int(current_tick)%5 == 0:
		var food_consumption_tick_value: float = 0.25
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
	value_changed.emit()
	return true

func get_new_resource(resource: String, productivity: float):
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

func meet_research_requirements(index):
	for i in researches[index]["conflicts"]:
		i = int(i)
		if researches[i]["researched"] == 1:
			return false
	if researches[index]["researched"]==1:
		return false
	for i in researches[index]["requirements"]:
		i = int(i)
		if researches[i]["researched"] == 0:
			return false
	return true

func can_afford_research(index):
	#if loading_save:
	#	index = str(index)
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

# Breeding and killing
func breeding() ->bool: #functions that calculates if two colonist are gonna breed together and returns false if somebody didnt and somebody did
	if len(colonist_dict) >=8:
		return false
	for house in housing_dictionary:
		var assigned = housing_dictionary[house]["assigned"]
		if assigned.size() >= 2:
			if Global.food > len(colonist_dict) * food_security_constant:
				if randf_range(0,50) < 1.0:
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
		"grieving_1": false,
		"homeless": false,
		"starving": false,
		"surgery": false,
		"grieving_2": false

}
	setup_colonist_body(child_name, get_colonist_sprite(), colonist_instances[parent1].get_home_position(parent1))
	update_sprite()
func update_sprite():
	for colonist in colonist_instances:
		var tex = colonist_instances[colonist].sprite.texture
		if tex != null:
			sprite_dict[colonist] = tex.resource_path
			#print(tex.resource_path)
		else:
			tex = get_colonist_sprite()
func update_position():
	for colonist in colonist_instances:
		position_dict[colonist] = colonist_instances[colonist].get_workstation_position(colonist_instances[colonist].assignment)
		if colonist_instances[colonist].rested == false:
			position_dict[colonist] = colonist_instances[colonist].get_home_position(colonist)
		if position_dict[colonist] == null:
			position_dict[colonist] = colonist_instances[colonist].get_random_building_position()
func kill_colonist(colonist_name: String, method):
	if colonist_name == leader:
		return
	if colonist_name not in colonist_dict:
		return
	possible_colonist_sprites.append(colonist_instances[colonist_name].sprite.texture.resource_path)
	colonist_dict.erase(colonist_name)
	workers_dict.erase(colonist_name)
	working_colonist.erase(colonist_name)
	happiness_dict.erase(colonist_name)
	colonist_instances[colonist_name].queue_free()
	colonist_instances.erase(colonist_name)
	sprite_dict.erase(colonist_name)
	position_dict.erase(colonist_name)
	Global.UI.colonists_card_dict[colonist_name].queue_free()
	Global.UI.colonists_card_dict.erase(colonist_name)
	for house in housing_dictionary:
		if colonist_name in housing_dictionary[house]["assigned"]:
			housing_dictionary[house]["assigned"].erase(colonist_name)
	for colonist in happiness_dict:
		if 14 not in colonist_dict[colonist]:
			print(colonist_dict[colonist])
			match method:
				"axe" :happiness_dict[colonist]["grieving_1"] = true
				"injection" :happiness_dict[colonist]["grieving_2"] = true
			if happiness_dict[colonist]["grieving_1"] and happiness_dict[colonist]["grieving_2"]:
				happiness_dict[colonist]["grieving_2"] = false
			grieving(colonist)
	update_sprite()
	flag_killed = true
	
func grieving(colonist):
	if 14 in colonist_dict[colonist] or 14.0 in colonist_dict[colonist]:
		if colonist in happiness_dict:
			happiness_dict[colonist]["grieving_1"] = false
			happiness_dict[colonist]["grieving_2"] = false
	if happiness_dict[colonist]["grieving_1"]:
		await get_tree().create_timer(90/Global.tick_interval).timeout
		if colonist in happiness_dict:
			happiness_dict[colonist]["grieving_1"] = false
	if colonist not in happiness_dict:
		return
	if happiness_dict[colonist]["grieving_2"]:
		await get_tree().create_timer(60/Global.tick_interval).timeout
		if colonist in happiness_dict:
			happiness_dict[colonist]["grieving_2"] = false
	value_changed.emit()
	

# Backend assignment
func assign_colonist_to_house(name, house): #helper funciton to assign a specific colonist to a specific house
	if len(housing_dictionary[house]["assigned"]) < housing_dictionary[house]["capacity"] and name not in housing_dictionary[house]["assigned"]:
		for i in housing_dictionary:
			if name in housing_dictionary[i]["assigned"]:
				housing_dictionary[i]["assigned"].erase(name)
				print(str(name) + " was removed from " + str(i))
				break
		housing_dictionary[house]["assigned"].append(name)
		value_changed.emit()
		print(str(name) + " was added to " + str(house))
	
			
			
		return true
	return false #returns false if the assignment was unsuccesfull
		
func assign_colonist_to_workplace(colonist_name: String, workplace: String) -> bool: #helper function to assign a specific colonist to a specific workplace
	if colonist_name not in colonist_dict:
		return false
	workers_dict[colonist_name] = workplace
	value_changed.emit()
	return true

# Backend building

func can_build_building(building_type: String) -> bool:
	if building_type == "plant_station":
		return true

	if building_type == "house":
		return researches.get(7, {}).get("researched", 0) == 1

	if building_type == "farm":
		return researches.get(3, {}).get("researched", 0) == 1

	if building_type == "mine":
		return researches.get(2, {}).get("researched", 0) == 1

	if building_type == "research_lab":
		return researches.get(1, {}).get("researched", 0) == 1
	return false
	
func can_afford_buildings(type: String) -> bool:
	match type:
		"house":
			return Global.minerals >= house_price[0] and Global.plant_matter >= house_price[1]

		"farm", "research_lab", "mine", "plant_station":
			return Global.plant_matter >= 10

		_:
			return false	
			
func can_upgrade_building(building: String) -> bool:
	# Only houses 
	if not housing_dictionary.has(building):
		return false
	return true

	# Upgrade 1 → 2 requires research nr 9
	if housing_dictionary[building]["capacity"] == 1:
		return researches[9]["researched"] == 1

	return false

func build_new_building(type: String) -> bool:
	if type == "food":
		type = "farm"
	elif type == "research":
		type = "research_lab"

	if not can_build_building(type):
		print("Building locked behind research")
		return false

	if not can_afford_buildings(type):
		print("Not enough resources")
		return false

	match type:
		"house":
			var house_count = 0
			for key in housing_dictionary.keys():
				if key.begins_with("house"):
					house_count += 1

			var id = "house" + str(house_count + 1)

			housing_dictionary[id] = {
				"capacity": 1,
				"assigned": []
			}

			resource_consumption("minerals", house_price[0])
			resource_consumption("plant_matter", house_price[1])

		"farm", "research_lab", "mine", "plant_station":
			workstation_dictionary[type] = {
				"assigned": []
			}

			resource_consumption("plant_matter", 10)

		_:
			print("Invalid building type")
			return false

	value_changed.emit()
	return true

func upgrade_building(building: String) -> bool:
#added print statements
	if not housing_dictionary.has(building):
		print("Building does not exist")
		return false

	if not can_upgrade_building(building):
		print("Upgrade locked")
		return false

	if not can_afford_upgrade(building):
		print("Not enough resources for upgrade")
		return false

	if housing_dictionary[building]["capacity"] == 1:
		housing_dictionary[building]["capacity"] = 2

		resource_consumption("minerals", house_upgrade1_price[0])
		resource_consumption("plant_matter", house_upgrade1_price[1])

		value_changed.emit()
		return true

	return false

func can_afford_upgrade(building: String) -> bool:
	return Global.minerals >= house_upgrade1_price[1] and Global.plant_matter >= house_upgrade1_price[0]
	
	
# apply research buff
func apply_research(index):
	match index:

		# RESEARCH
		1:
			research_prod_modifier += 0.05
			$UI/Background/Research.frame = 1
		29:
			research_prod_modifier += 0.1

		10:
			research_prod_modifier += 0.20

		14:
			research_prod_modifier += 0.05


		# PLANTS
		6:
			plant_prod_modifier *= 5
			$UI/Background/Path/Trees.frame = 1
		18:	
			plant_prod_modifier *= 10


		# FOOD
		3:
			food_prod_modifier *= 1.15
			$UI/Background/Farm.frame = 1
		5:
			food_prod_modifier *= 1.25
			$UI/Background/Farm.frame = 2

		13:
			food_prod_modifier *= 1.30
			$UI/Background/Farm.frame = 2

		21:
			food_prod_modifier *= 1.50
			$UI/Background/Farm.frame = 2


		# MINERALS
		2:
			minerals_prod_modifier *= 1
		8:
			minerals_prod_modifier *= 5
			$UI/Background/Cave.frame =1
		16:
			minerals_prod_modifier *= 10
			$UI/Background/Cave.frame = 2

		#Decor
		4:
			Global.decorations +=5
		11: 
			Global.decorations +=5
		12:
			Global.decorations +=5
		17:
			Global.decorations +=5
		
		#Ending 3
		28:
			win_game("pod")
			Global.average_happiness = 100
		
		#Ending 2
		34:
			leader = colonist_dict.keys().pick_random()
			print(leader)
		35:
			research_prod_modifier*=3
			minerals_prod_modifier*=3
			plant_prod_modifier*=3
			food_prod_modifier*=3
		37:
			ritual_sacrifice()
			win_game("religion")
			Global.average_happiness = 100

# Happiness calcs
func ritual_sacrifice():
	var to_kill = []
	for colonist in colonist_dict:
		if colonist != leader:
			to_kill.append(colonist)
	for colonist in to_kill:
		kill_colonist(colonist, "axe")

func happiness_tick():
	var happy_base = 20
	happy_base += Global.decorations
	if Global.food < 1:
		happy_base-=10
	else:
		happy_base+=10
	for colonist in happiness_dict:
		#Lazy not to rewrite here
		if Global.food < 1:
			happiness_dict[colonist]["starving"] = true
	
		#The rest is fine
		
		if colonist_instances[colonist].state=="working" and "workaholic" not in colonist_dict[colonist]:
			happy_base-=5
		if happiness_dict[colonist]["sick"] == true:
			happy_base-=10
		#Check if homeless
		var homeless = true
		for i in housing_dictionary:
			if colonist in housing_dictionary[i]["assigned"]:
				happiness_dict[colonist]["homeless"] = false
				homeless = false
		if homeless:
			happiness_dict[colonist]["homeless"] = true
		if happiness_dict[colonist]["homeless"]:
			happy_base-=10
			
		if happiness_dict[colonist]["surgery"]:
			happy_base-=10
		#Prevent double grieving
		if happiness_dict[colonist]["grieving_1"] and happiness_dict[colonist]["grieving_2"]:
			happiness_dict[colonist]["grieving_2"] = false
		
		if happiness_dict[colonist]["grieving_1"]:
			happy_base-=10
		if happiness_dict[colonist]["grieving_2"]:
			happy_base-=5
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

func sick_tick():
	for colonist in happiness_dict:
		var sickness_mod = 1
		for i in colonist_dict[colonist]:
			i = int(i)
			sickness_mod*= trait_dict[i]["sickness_chance"]
		if happiness_dict[colonist]["sick"] != true:
			var homeless = 0
			if happiness_dict[colonist]["homeless"]:
				homeless = 1
			if randi_range(0,100)*sickness_mod + 3*homeless > 97:
				happiness_dict[colonist]["sick"] = true
		else:
			
			if randi_range(0,100) +5*researches[22]["researched"] > 99:
				happiness_dict[colonist]["sick"] = false
