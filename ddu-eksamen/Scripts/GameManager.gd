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
