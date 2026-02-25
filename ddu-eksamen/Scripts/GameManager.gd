extends Node

var colonist_amount 
var colonist_dict:Dictionary = {}
var assignment_dict:Dictionary = {}
var name_array =  ["Alice", "Bob", "Jones", "Lones", "Eliot","Frederik", "Sirius", "Jens", "Sofie", "David", "Christian"]
var genetics_array = []

func add_colonist(name, trait_1, trait_2, trait_3, trait_4, trait_5, trait_6):
	var data := {
		"trait_1": trait_1,
		"trait_2": trait_2,
		"trait_3": trait_3,
		"trait_4": trait_4,
		"trait_5": trait_5,
		"trait_6": trait_6
	}
	colonist_dict[name] = data

var current_tick = 0

#func add_colonist(name,trait_1,trait_2,trait_3,trait_4,trait_5,trait_6):
#	colonist_dict.append({
#	"id":001,"name":name,trait 
#})
#	pass

func generate_colonist_name():
	return name_array.pick_random()

func generate_trait_array():
	var temp_trait_array = []
	var duplicate_genetic_array = genetics_array.duplicate()
	for number in 6:
		var random = duplicate_genetic_array.pick_random()
		temp_trait_array.append(random)
		duplicate_genetic_array.erase(random)
	duplicate_genetic_array.clear()
	return temp_trait_array
	
		
func _ready():
	pass

func get_new_colony(amount):
	for colonist in amount:
		var colonist_name = generate_colonist_name()
		var trait_array:Array = generate_trait_array()
		pass

#TICK SYSTEM
func _on_tick_timer_timeout() -> void:
	current_tick+=1
	print(current_tick)
	pass # Replace with function body.
