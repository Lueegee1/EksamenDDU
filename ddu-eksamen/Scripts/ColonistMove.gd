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
var speed = 20
var rested =true
var wandered = false
var building_positions = {}
var turn = 1
var direction_timer = 0.0
var direction_interval = 2
var turn_speed = 0.5
var moving_randomly = true

func setup(sprt, nme, pos):
	colonist_name = nme
	print(str(sprt))
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
	if workplace == "unemployed":
		return get_random_building_position()
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
	#print(building_positions[random_key])
	return building_positions[random_key]
func get_random_rest_position() -> Vector2:
	var keys = building_positions.keys()
	var filtered = keys.filter(func(x): return x not in ["farm", "research_lab", "mine", "forest"])
	var random_key = filtered.pick_random()
	#print(building_positions[random_key])
	return building_positions[random_key]
	
func colonist_work_day():
	Global.GameManager.update_position()
	state = "working"
	sprite.skew = 0
	if colonist_name not in Global.GameManager.colonist_dict:
		return
	if "workaholic" in Global.GameManager.colonist_dict[colonist_name]:
		await get_tree().create_timer((Global.GameManager.workday_lenght*1.5)/Global.tick_interval).timeout
	await get_tree().create_timer((Global.GameManager.workday_lenght)/Global.tick_interval).timeout
	rested = false
	state = "going_home"
func colonist_rest():
	Global.GameManager.update_position()
	state = "resting"
	sprite.skew = 0
	sprite.rotation = 0
	await get_tree().create_timer(5/Global.tick_interval).timeout
	rested = true
	state = "going_to_work"
func wiggle(delta):
	direction_timer += delta
	if direction_timer >= direction_interval/Global.tick_interval:
		turn *= -1
		direction_timer=0
	sprite.skew = lerp(sprite.skew,turn*0.0,turn_speed*Global.tick_interval*delta)
	sprite.rotation = lerp(sprite.rotation,0.2*turn,turn_speed*Global.tick_interval*delta)

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
	position += direction * speed*Global.tick_interval * delta * randf_range(0.8,1)
	wiggle(delta)


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
				agent.target_position = Vector2.ZERO
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
			
			if agent.target_position == Vector2.ZERO or agent.is_navigation_finished() and not wandered and rested:
				wandered = true
				var new_target = get_random_building_position()
				agent.target_position = new_target
			if agent.target_position == Vector2.ZERO or agent.is_navigation_finished() and not wandered and not rested:
				wandered = true
				var new_target = get_random_rest_position()
				agent.target_position = new_target
			
			if wandered and rested and moving_randomly:
				#changed destination randomly
				if not int(Global.GameManager.current_tick)%5>0:
					#print("PIKMIN " +str(wandered))
					if randf_range(0,99)<=5:
						var new_target = get_random_building_position()
						agent.target_position = new_target
						moving_randomly = false
					
			_step_agent(delta)
			if wandered and not rested and agent.is_navigation_finished():
				wandered = false
				moving_randomly = true
				colonist_rest()
			if wandered and rested and agent.is_navigation_finished():
				wandered = false
				moving_randomly = true
				state = "idle"
			
func _process(delta: float) -> void:
	colonist_move(delta*5)
	if state == "working":
		wiggle(delta)
	
	pass
	
func is_position_in_navregion(pos: Vector2, region: NavigationRegion2D) -> bool:
	var closest_point = NavigationServer2D.map_get_closest_point(region.get_navigation_map(), pos)
	return pos.distance_to(closest_point) < 1.0

func _on_texture_button_pressed() -> void:
	Global.UI.build_open = false
	Global.UI.research_open = false
	Global.UI.colonist_open = true
	Global.UI._on_button_pressed(Global.UI.buttons[8])
	
	pass # Replace with function body.
