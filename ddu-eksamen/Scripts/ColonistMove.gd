extends Node2D
func die():
	queue_free()
	Global.GameManager.colonist_instances.erase(colonist_name)
var assignment: String
@onready var sprite = $Sprite2D
@onready var agent = $NavigationAgent2D
var state = "idle"
var colonist_name: String
var productivity
const speed = 10
var rested =true
var wandered = false
var building_positions = {}

func setup(sprt, nme, pos):
	colonist_name = nme
	sprite.texture = load(sprt)
	sprite.scale =Vector2(4,4)
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
	var filtered = keys.filter(func(x): return x != assignment)
	var random_key = filtered.pick_random()
	return building_positions[random_key]
	
func colonist_work_day():
	state = "working"
	await get_tree().create_timer(60).timeout
	rested = false
	state = "going_home"
func colonist_rest():
	rested = true
	state = "resting"
	await get_tree().create_timer(10).timeout
	state = "going_to_work"

func _step_agent(delta) -> void:
	var next_pos = agent.get_next_path_position()
	# Prevent NaN / zero movement bugs
	if next_pos == Vector2.ZERO:
		return

	var direction = (next_pos - position).normalized()
	
	if position.distance_to(next_pos) < 1.0:
		return
	if next_pos.distance_to(position) < 10:
		next_pos += Vector2(
			randf_range(0, 20),
			randf_range(0, 20))
	position += direction * speed * delta * randf_range(0.8,1)

func colonist_move(delta: float) -> void:
	if colonist_name in Global.GameManager.workers_dict:
		assignment = Global.GameManager.workers_dict[colonist_name]
	if rested:
		match assignment:
			"farm": state = "going_to_work"
			"plants": state = "going_to_work"
			"mine": state = "going_to_work"
			"research_lab": state = "going_to_work"
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
				colonist_work_day()
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
				state = "resting"
				colonist_rest()
			else:
				_step_agent(delta)

		"working":
			pass
		"resting":
			pass

		"wandering":
			
			if agent.target_position == Vector2.ZERO or agent.is_navigation_finished() and not wandered:
				wandered = true
				var new_target = get_random_building_position()
				agent.target_position = new_target
			_step_agent(delta)
			if wandered and not rested and agent.is_navigation_finished():
				wandered = false
				colonist_rest()
			if wandered and rested and agent.is_navigation_finished():
				wandered = false
				state = "idle"
			
func _process(delta: float) -> void:
	colonist_move(delta*5)
	pass
	
