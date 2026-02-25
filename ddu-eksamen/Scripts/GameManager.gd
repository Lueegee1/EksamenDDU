extends Node

var colonist_amount 
var colonist_dict = {}

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

func _ready():
	pass

#TICK SYSTEM
func _on_tick_timer_timeout() -> void:
	current_tick+=1
	print(current_tick)
	pass # Replace with function body.
