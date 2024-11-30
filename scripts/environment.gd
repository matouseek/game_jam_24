extends Node2D

const ENV_SIZE: int = 12

var last_selected = [Vector2i(-1000,-1000)]

var offsets = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),               Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)]

var terrain: Array = []

func _ready() -> void:
	for i in range(ENV_SIZE):
		var row: Array = []
		for j in range(ENV_SIZE):
			row.append(G.TileTypes.MEADOW)
		terrain.append(row)
	initialize_randomly()
	set_map()
	calc_distribution()
	
	
	
func _input(event):
	if event is InputEventMouse:
		var pos = $TileMapLayer.local_to_map(get_local_mouse_position())
		if (is_valid_click_pos(pos)):
			if event.is_action_pressed("mouse_click"):
				confirm_tile_selection()
			handle_highlights(pos)
	if Input.is_action_pressed("ui_accept"):
		erase_all_effects()

func calc_distribution():
	var vals = [0.0,0.0,0.0]
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			vals[terrain[i][j]] += 1
	var all = ENV_SIZE*ENV_SIZE
	var vals_percent = []
	for i in range(len(vals)):
		vals_percent.append(vals[i]/all)
	HUD.update_progress(vals_percent)

func is_valid_click_pos(pos : Vector2i) -> bool:
	return pos.x >= 0 and pos.x < ENV_SIZE and pos.y >= 0 and pos.y< ENV_SIZE

func confirm_tile_selection() -> void:
	for lpos in last_selected: # confirm selection
		$Used.set_cell(lpos,PS.selected_effect,Vector2i(0,0))

func handle_highlights(pos: Vector2i) -> void:
	if (last_selected[0] != pos): # check if cursor moved to new location
		for lpos in last_selected:
			$Highlight.set_cell(lpos,-1,Vector2i(0,0))
		last_selected = [pos]
		
		$Highlight.set_cell(pos,PS.selected_effect,Vector2i(0,0))
		if (PS.PlayerEffects.MAJORITY == PS.selected_effect):
			highligh_neighbors(pos)

func highligh_neighbors(pos : Vector2i) -> void:
	for offset in offsets:
		var newpos = pos+offset
		if (newpos.x >= 0 and newpos.x < ENV_SIZE and newpos.y >= 0 and newpos.y<ENV_SIZE):
			last_selected.append(newpos)
			$Highlight.set_cell(newpos,PS.selected_effect,Vector2i(0,0))

func erase_all_effects() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$Used.set_cell(Vector2i(i,j),-1,Vector2i(0,0))

func initialize_randomly() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			terrain[i][j] = randi_range(0,2)
#			if (j== ENV_SIZE-1 and i == ENV_SIZE-1): terrain[i][j] = -1
#			elif (j == ENV_SIZE-1 or i == ENV_SIZE-1): terrain[i][j] = 2
#			else : terrain[i][j] = randi_range(0,1)

func set_map() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$TileMapLayer.set_cell(Vector2i(i,j),terrain[i][j],Vector2i(0,0))
