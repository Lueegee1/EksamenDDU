extends Node2D
func die():
	queue_free()
	Global.GameManager.colonist_instances.erase(colonist_name)

@onready var sprite = $Sprite2D
@onready var agent = $NavigationAgent2D
var state = "idle"
var colonist_name: String
var productivity
const speed = 5

var building_positions = {}

func setup(sprt, nme, pos):
	colonist_name = nme
	sprite.texture = load(sprt)
	sprite.scale =Vector2(0.1,0.1)
	#productivity = prod
	position = pos
	var nav_region = get_tree().get_root().find_child("NavigationRegion2D", true, false)
	if nav_region:
		agent.set_navigation_map(nav_region.get_navigation_map())
	_load_building_positions()
	
func _load_building_positions() -> void:
	var markers_node = get_tree().get_root().find_child("Buldingmarkers", true, false)
	if markers_node == null:
		return
	for marker in markers_node.get_children():
		building_positions[marker.name.to_lower()] = marker.global_position
	
func get_workstation_position(workplace: String) -> Vector2:
	return building_positions.get(workplace, Vector2.ZERO)
func get_home_position(colonist: String):
	for house_id in Global.GameManager.housing_dictionary:
		if "assigned" in Global.GameManager.housing_dictionary[house_id] and colonist in Global.GameManager.housing_dictionary[house_id]["assigned"]:
			return building_positions.get(house_id, Vector2.ZERO)
	return null
func get_random_building_position() -> Vector2:
	var keys = building_positions.keys()
	var random_key = keys.pick_random()
	return building_positions[random_key]
	
func colonist_work_day(colonist_name):
	state = "going_to_work"
	await get_tree().create_timer(300.0).timeout
	state = "going_home"

func _step_agent(delta) -> void:
	var next_pos = agent.get_next_path_position()
	# Prevent NaN / zero movement bugs
	if next_pos == Vector2.ZERO:
		return

	var direction = (next_pos - position).normalized()

	if position.distance_to(next_pos) < 1.0:
		return

	position += direction * speed * delta

func colonist_move(delta: float) -> void:
	var assignment = Global.GameManager.workers_dict[colonist_name]
	
	match assignment:
		"farm": state = "going_to_work"
		"plants": state = "going_to_work"
		"mine": state = "going_to_work"
		"research_table": state = "going_to_work"
		"unemployed": state = "wandering"
		
	match state:
		"idle":
			if assignment == "unemployed":
				state = "wandering"
				agent.target_position = Vector2(
					randf_range(50, 1870), randf_range(50, 1030)
					)
			else:
				state = "going_to_work"
				agent.target_position = get_workstation_position(assignment)

		"going_to_work":
			agent.target_position = get_workstation_position(assignment)
			if agent.is_navigation_finished():
				state = "working"
				colonist_work_day(colonist_name)
			else:
				_step_agent(delta)

		"going_home":
			var target = get_home_position(colonist_name)
			if target == null:
				state= "wandering"
				agent.target_position = Vector2(
					randf_range(50, 1870), randf_range(50, 1030))
				return
			agent.target_position = target
			if agent.is_navigation_finished():
				state = "going_to_work"
			else:
				_step_agent(delta)

		"working":
			pass

		"wandering":
			
			if agent.target_position == Vector2.ZERO or agent.is_navigation_finished():
				var new_target = get_random_building_position()

				#if new_target.distance_to(position) < 10:
				#	new_target += Vector2(
				#		randf_range(-100, 100),
				#		randf_range(-100, 100)
				#	)

				agent.target_position = new_target

			_step_agent(delta)

func _process(delta: float) -> void:
	colonist_move(delta*5)
	pass
	
