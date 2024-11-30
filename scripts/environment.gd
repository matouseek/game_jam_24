extends Node2D

const ENV_SIZE: int = 12

var fuck_up_effects : Array[PlacedEffect] = []
var used_effects : Array[PlacedEffect] = []

var last_selected = [Vector2i(-1000,-1000)]

var offsets = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
			   Vector2i(-1,  0),                  Vector2i(1,  0),
			   Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)]

var terrain: Array = []

func _ready() -> void:
	for i in range(ENV_SIZE):
		var row: Array[WorldTile] = []
		for j in range(ENV_SIZE):
			var default_tile : WorldTile = WorldTile.new(G.get_rand_tile_type(),G.TileTier.MEDIUM)
			row.append(default_tile)
		terrain.append(row)
	initialize_randomly()
	render_map()
	G.set_goals_distribution(calc_distribution())
	
func _input(event):
	if not PS.is_player_turn: return
	if event is InputEventMouse:
		var pos = $TileMapLayer.local_to_map(get_local_mouse_position())
		if (is_valid_map_pos(pos)):
			if event.is_action_pressed("mouse_click") and PS.remaining_actions != 0:
				PS.remaining_actions -= 1
				PS.update_player_action_amount(PS.remaining_actions)
				confirm_tile_selection()
				render_all_effects()
			handle_highlights(pos)
		else: # if player points out of map region
			clear_all_highlights()
	elif Input.is_action_just_pressed("undo"):
		reset_last_used_effect()
	if Input.is_action_just_pressed("ui_accept"):
		update_tiers()
		test_print_board()



func calc_distribution() -> Array[float]:
	var tier_boost_coeff : int = 2
	update_tiers()
	var tile_counts_weighted = [0.0,0.0,0.0]
	var total_count : int = 0
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			var count_to_add : int = pow(terrain[i][j].tier + 1,tier_boost_coeff)
			tile_counts_weighted[terrain[i][j].type] += count_to_add
			total_count += count_to_add
	var tile_percents : Array[float]= [0.0,0.0,0.0]
	for i in range(len(tile_counts_weighted)):
		tile_percents[i] = tile_counts_weighted[i]/total_count
	G.update_progress(tile_percents)
	return tile_percents

func is_valid_map_pos(pos : Vector2i) -> bool:
	return pos.x >= 0 and pos.x < ENV_SIZE and pos.y >= 0 and pos.y< ENV_SIZE

func confirm_tile_selection() -> void:
	used_effects.append(PlacedEffect.new(last_selected[0],PS.selected_effect))

func clear_all_highlights() -> void: # used when cursor out of map region
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$Highlight.set_cell(Vector2i(i,j),-1,Vector2i(0,0))

func handle_highlights(pos: Vector2i) -> void:
	if (last_selected[0] != pos): # check if cursor moved to new location
		for lpos in last_selected:
			$Highlight.set_cell(lpos,-1,Vector2i(0,0))
		last_selected = [pos]
		
		$Highlight.set_cell(pos,PS.selected_effect,Vector2i(0,0))
		if (PS.PlayerEffects.MAJORITY == PS.selected_effect):
			highligh_neighbors(pos)

func render_all_effects() -> void:
	clear_effects_visuals()
	for effect in fuck_up_effects + used_effects:
		$Used.set_cell(effect.source_coord,effect.type,Vector2i(0,0))
		if effect.type == PS.PlayerEffects.MAJORITY: # handle majority effect rendering
			for offset in offsets:
				var newpos = effect.source_coord+offset
				if (newpos.x >= 0 and newpos.x < ENV_SIZE and newpos.y >= 0 and newpos.y<ENV_SIZE):
					last_selected.append(newpos)
					$Used.set_cell(newpos,effect.type,Vector2i(0,0))

func highligh_neighbors(pos : Vector2i) -> void:
	for offset in offsets:
		var newpos = pos+offset
		if (newpos.x >= 0 and newpos.x < ENV_SIZE and newpos.y >= 0 and newpos.y<ENV_SIZE):
			last_selected.append(newpos)
			$Highlight.set_cell(newpos,PS.selected_effect,Vector2i(0,0))

func clear_effects_visuals() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$Used.set_cell(Vector2i(i,j),-1,Vector2i(0,0))

func initialize_randomly() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			terrain[i][j] = WorldTile.new(G.get_rand_tile_type(),G.TileTier.MEDIUM)
#			if (j== ENV_SIZE-1 and i == ENV_SIZE-1): terrain[i][j] = -1
#			elif (j == ENV_SIZE-1 or i == ENV_SIZE-1): terrain[i][j] = 2
#			else : terrain[i][j] = randi_range(0,1)

func render_map() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$TileMapLayer.set_cell(Vector2i(i,j),terrain[i][j].type,Vector2i(0,0))

func reset_effects() -> void:
	used_effects = []
	fuck_up_effects = []

func get_random_map_coord() -> Vector2i:
	var pos_x : int = randi_range(0,ENV_SIZE-1)
	var pos_y : int = randi_range(0,ENV_SIZE-1)
	return Vector2i(pos_x,pos_y)

func reset_last_used_effect() -> void:
	if used_effects.is_empty(): return
	used_effects.remove_at(used_effects.size() - 1)
	PS.remaining_actions += 1
	PS.update_player_action_amount(PS.remaining_actions)
	render_all_effects()

func test_print_board():
	for i in range(ENV_SIZE):
		var string : String = ""
		for j in range(ENV_SIZE):
			string += terrain[i][j].get_str()
		print(string)

func update_tiers() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			update_tile_tier(Vector2i(i,j))

func update_tile_tier(coord : Vector2i) -> void:
	var neigh_coords : Array[Vector2i] = $TileMapLayer.get_surrounding_cells(coord)
	var cur_type : G.TileTypes = terrain[coord.x][coord.y].type
	var friends_count : int = 0
	
	# detect neighboring tiles with same type
	for neigh in neigh_coords:
		if not is_valid_map_pos(neigh):
			continue
		if terrain[neigh.x][neigh.y].type == cur_type:
			friends_count += 1
	
	# determine tier based on amount of neighbors with same type
	if friends_count < 2:
		terrain[coord.x][coord.y].tier = G.TileTier.LOW
	elif friends_count < 4:
		terrain[coord.x][coord.y].tier = G.TileTier.MEDIUM
	else:
		terrain[coord.x][coord.y].tier = G.TileTier.HIGH
