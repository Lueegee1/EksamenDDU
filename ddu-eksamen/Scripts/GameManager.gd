extends Node

var amount:Array = [6,7,8]
var colonist_amount 
var colonist_dict:Dictionary = {}
var assignment_dict:Dictionary = {}
var name_array =  ["Alice", "Bob", "Jones", "Lones", "Eliot","Frederik", "Sirius", "Jens", "Sofie", "David", "Christian"]
var genetics_array = []

var trait_dict = {
	000:{"name":"Neutral","productivity_mod":1,"happiness_mod":1,"sickness_chance":1},
	001:{"name":"Sanguine","productivity_mod":1,"happiness_mod":1.1,"sickness_chance":1},
	002:{"name":"Pessimistic","productivity_mod":1,"happiness_mod":0.9,"sickness_chance":1},
	003:{"name":"Effective","productivity_mod":1.2,"happiness_mod":1,"sickness_chance":1},
	004:{"name":"Lazy","productivity_mod":0.8,"happiness_mod":1,"sickness_chance":1},
	005:{"name":"Healthy","productivity_mod":1,"happiness_mod":1,"sickness_chance":0.5},
	006:{"name":"Sickly","productivity_mod":1,"happiness_mod":1,"sickness_chance":2},
}
#----------------------------------------------------------------------


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

func generate_starter_trait_array(amount):
	var temp_trait_array = []
	var duplicate_genetic_array = genetics_array.duplicate()
	for number in amount:
		var random = duplicate_genetic_array.pick_random()
		temp_trait_array.append(random)
		duplicate_genetic_array.erase(random)
	duplicate_genetic_array.clear()
	return temp_trait_array
	
		
func _ready():
	pass
	#get_new_colony(amount)

func get_new_colony(amount):
	var number = amount.pick_random()
	for colonist in amount:
		var colonist_name = generate_colonist_name()
		var trait_array:Array = generate_starter_trait_array(number)
		pass

#TICK SYSTEM
func _on_tick_timer_timeout() -> void:
	current_tick+=1
	print(current_tick)
	pass # Replace with function body.
