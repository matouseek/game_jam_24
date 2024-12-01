extends Node

const GODS_ACTION_PROB_DISTR : Array[float] = [0.4,0.4,0.2] # RAIN, DRAUGHT, MAJORITY
const GODS_ACTION_COUNT : int = 2

@onready var env: Node2D = $Environment

const MAX_ROUNDS : int = 10
var round_num : int = 0
const ZOOM_COEF = 1.25
const CAM_SPEED = 2200
var limit_camera = true
const ZOOM_FACTOR_MAX = 1.75
const ZOOM_FACTOR_MIN = 0.2
var zoom_factor = 0.25
@onready var camera = $Camera2D
const TRANS_TIME = 4
var camera_start_pos = null
var turns = 10
var win = false
func _ready() -> void:
	camera_start_pos = camera.position
	$CameraUnlock.start()
	HUD.do_will.connect(_on_will_done)
	camera.zoom = Vector2(zoom_factor,zoom_factor)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(camera, "position", Vector2(500,3000),TRANS_TIME).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "zoom", Vector2(0.2,0.2),TRANS_TIME).set_trans(Tween.TRANS_CUBIC)
	$Environment.visible = true
	add_fuck_ups()
	PS.reset_player_actions_amount()
	#HUD.set_error_margins_scale(G.GOAL_ERROR_MARGIN*2)

func start_tutorial() -> void:
	HUD.visible = true
	if (PS.tutorial):
		AS.tutorial()
		T.process_mode = Node.PROCESS_MODE_ALWAYS
		#$CameraUnlock.stop()
		get_tree().paused = true
		HUD.zeroth_step()

func _input(event: InputEvent) -> void:
	if (!limit_camera):
		if (event.is_action_pressed("zoom_in")):
			zoom_factor = min(zoom_factor*ZOOM_COEF,ZOOM_FACTOR_MAX)
			camera.zoom = Vector2(zoom_factor,zoom_factor)
		if (event.is_action_pressed("zoom_out")):
			zoom_factor = max(zoom_factor/ZOOM_COEF,ZOOM_FACTOR_MIN)
			camera.zoom = Vector2(zoom_factor,zoom_factor)

func _process(delta: float) -> void:
	if (!limit_camera):
		var dir = Vector2(Input.get_action_strength("right")-Input.get_action_strength("left"),
		Input.get_action_strength("down")-Input.get_action_strength("up"))
		dir = dir.normalized()
		var update = camera.position + (CAM_SPEED/zoom_factor)*delta*dir
		if (update.x <= camera.limit_left):
			update.x = camera.limit_left
		elif (update.x >= camera.limit_right):
			update.x = camera.limit_right
		if (update.y <= camera.limit_top):
			update.y = camera.limit_top
		elif (update.y >= camera.limit_bottom):
			update.y = camera.limit_bottom

		
		if (Input.is_action_pressed("end")): end()
		camera.position = update
		
	
func _on_will_done() -> void:
	turns-=1
	PS.is_player_turn = false
	HUD.set_will_be_done_visibility(false)

	env.clear_all_highlights()	
	
	print("Process player selection")
	await process_used_effects()
	
	print("Process fuck ups")
	await process_fuck_ups()
	
	env.calc_distribution()
	
	print("Won game: ", is_goal_reached(G.goal_percentages,G.current_percentages,G.GOAL_ERROR_MARGIN))
	update_round_count()
	
	env.clear_effects_visuals()
	
	print("Clear board")
	env.reset_effects()
	if (is_goal_reached(G.goal_percentages,G.current_percentages,G.GOAL_ERROR_MARGIN)):
		win = true
		end()
	if (turns == 9):
		end()
	print("Add fuck ups for next round")
	add_fuck_ups()
	# now wait for player to make selection and then press will be done
	
	HUD.set_will_be_done_visibility(true)
	PS.reset_player_actions_amount()
	PS.is_player_turn = true

func is_goal_reached(goal_distr : Array[float], cur_dist : Array[float], margin_error : float) -> bool:
	for i in range(len(goal_distr)):
		if cur_dist[i] < goal_distr[i] - margin_error or cur_dist[i] > goal_distr[i] + margin_error:
			return false
	return true

func update_round_count() -> void:
	round_num += 1
	HUD.update_round_label(round_num)

func add_fuck_ups() -> void:
	var new_fuck_ups : Array[PlacedEffect] = []
	for i in range(GODS_ACTION_COUNT):
		var pos : Vector2i = env.get_random_map_coord()
		new_fuck_ups.append(PlacedEffect.new(pos,PS.get_rand_effect_type(GODS_ACTION_PROB_DISTR)))
	env.fuck_up_effects = new_fuck_ups
	env.render_all_effects()

func process_fuck_ups() -> void:
	if env.fuck_up_effects.is_empty():
		await get_tree().create_timer(0.2).timeout
	var terrain_copy: Array
	for fuck_up_effect in env.fuck_up_effects:
		terrain_copy = env.get_terrain_copy()
		process_effect(fuck_up_effect)
		env.update_tiers()
		env.tween_tilemap(terrain_copy, env.terrain)
		# Doesnt work when timer is too low or removed
		# Tileset is written too early if removed or lowered
		await wait_if_terrain_diff(terrain_copy, env.terrain)

func process_used_effects() -> void:
	if env.used_effects.is_empty():
		await get_tree().create_timer(0.2).timeout
	var terrain_copy: Array
	for used_effect in env.used_effects:
		terrain_copy = env.get_terrain_copy()
		process_effect(used_effect)
		env.update_tiers()
		env.tween_tilemap(terrain_copy, env.terrain)
		# Doesnt work when timer is too low or removed
		# Tileset is written too early if removed or lowered
		await wait_if_terrain_diff(terrain_copy, env.terrain)
	
func wait_if_terrain_diff(old_terrain, new_terrain) -> bool:
	for i in range(env.ENV_SIZE):
		for j in range(env.ENV_SIZE):
			var old_tile : WorldTile = old_terrain[i][j]
			var new_tile : WorldTile = new_terrain[i][j]
			if old_tile.type != new_tile.type or old_tile.tier != new_tile.tier: 
				await get_tree().create_timer(1.5).timeout
				return true
	return false

func process_effect(effect: PlacedEffect) -> void:
	match effect.type:
		PS.PlayerEffects.RAIN:
			process_rain(effect)
		PS.PlayerEffects.DRAUGHT:
			process_draught(effect)
		PS.PlayerEffects.MAJORITY:
			process_majority(effect)

func process_rain(rain_effect: PlacedEffect) -> void:
	var tile: G.TileTypes = env.terrain[rain_effect.source_coord.x][rain_effect.source_coord.y].type
	match tile:
		G.TileTypes.DESERT:
			env.terrain[rain_effect.source_coord.x][rain_effect.source_coord.y].type = G.TileTypes.MEADOW
		G.TileTypes.MEADOW:
			env.terrain[rain_effect.source_coord.x][rain_effect.source_coord.y].type = G.TileTypes.WATER
		G.TileTypes.WATER:
			print("Rained on water")
	
func process_draught(draught_effect: PlacedEffect) -> void:
	var tile: G.TileTypes = env.terrain[draught_effect.source_coord.x][draught_effect.source_coord.y].type
	match tile:
		G.TileTypes.DESERT:
			print("Draught on desert")
		G.TileTypes.MEADOW:
			env.terrain[draught_effect.source_coord.x][draught_effect.source_coord.y].type = G.TileTypes.DESERT
		G.TileTypes.WATER:
			env.terrain[draught_effect.source_coord.x][draught_effect.source_coord.y].type = G.TileTypes.MEADOW

func get_unique_max_index_or_neg(amounts : Array[int]) -> int:
	var first_max_index : int = 0
	var last_max_index : int = 0
	for i in range(len(amounts)):
		if amounts[i] > amounts[first_max_index]:
			first_max_index = i
	for i in range(len(amounts)):
		if amounts[i] >= amounts[last_max_index]:
			last_max_index = i
	if first_max_index == last_max_index:
		return first_max_index
	else:
		return -1

func process_majority(majority_effect: PlacedEffect) -> void:
	var amounts: Array[int] = []
	amounts.resize(G.TileTypes.size())
	
	var start_tile: Vector2i = Vector2i(majority_effect.source_coord.x - 1, majority_effect.source_coord.y - 1)
	for i in range(3):
		for j in range(3):
			# Check if tile is on grid
			var current_tile : Vector2i = start_tile + Vector2i(i,j)
			if not env.is_valid_map_pos(current_tile):
				continue
			var tile: G.TileTypes = env.terrain[current_tile.x][current_tile.y].type
			match tile:
				G.TileTypes.DESERT:
					amounts[G.TileTypes.DESERT] += 1
				G.TileTypes.MEADOW:
					amounts[G.TileTypes.MEADOW] += 1
				G.TileTypes.WATER:
					amounts[G.TileTypes.WATER] += 1
	
	var max_index: int = get_unique_max_index_or_neg(amounts)
	var resulting_tile : G.TileTypes = env.terrain[majority_effect.source_coord.x][majority_effect.source_coord.y].type
	if max_index >= 0: # we found unique max
		resulting_tile = max_index
	
	for i in range(3):
		for j in range(3):
			# Check if tile is on grid
			var current_tile : Vector2i = start_tile + Vector2i(i,j)
			if not env.is_valid_map_pos(current_tile):
				continue
			env.terrain[current_tile.x][current_tile.y].type = resulting_tile


func _on_camera_unlock_timeout() -> void:
	camera.limit_bottom = 8000
	camera.limit_top = -3000
	camera.limit_left = -7000
	camera.limit_right = 8500
	limit_camera = false
	start_tutorial()
	

func end():
	HUD.visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	$Environment.process_mode = Node.PROCESS_MODE_ALWAYS
	$Timer.process_mode = Node.PROCESS_MODE_ALWAYS
	var tween = get_tree().create_tween()
	$Timer.wait_time = TRANS_TIME-1
	$Timer.start()
	tween.tween_property($Environment,"modulate",Color(1,1,1,0),TRANS_TIME-1)


func _on_timer_timeout() -> void:
	if (win):END.won()
	else: END.lost()
