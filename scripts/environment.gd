extends Node2D

const TIER_BOOST_COEFF : float = 2.5
const ENV_SIZE: int = 12

var type_modulo : int = 10
var tier_modulo : int = 3

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
			var default_tile : WorldTile = WorldTile.new(G.get_rand_tile_type(),G.TileTier.MEDIUM,G.TileTier.MEDIUM)
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
			last_selected = [Vector2i(-1000,-1000)]
			clear_all_highlights()
	elif Input.is_action_just_pressed("undo"):
		reset_last_used_effect()
	if Input.is_action_just_pressed("ui_accept"):
		update_tiers()
		test_print_board()



func calc_distribution() -> Array[float]:
	update_tiers()
	var tile_counts_weighted = [0.0,0.0,0.0]
	var total_count : int = 0
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			var count_to_add : int = pow(terrain[i][j].tier + 1,TIER_BOOST_COEFF)
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
			terrain[i][j] = WorldTile.new(G.get_rand_tile_type(),G.TileTier.MEDIUM,G.TileTier.MEDIUM)
	update_tiers()
	
func render_map() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$TileMapLayer.set_cell(Vector2i(i,j),get_tile_source_id(terrain[i][j]),Vector2i(0,0))

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

func tween_out_tile(coord: Vector2i) -> void:
	var tilemaplayer: TileMapLayer = $TileMapLayer
	var texture: Texture2D = get_cell_texture(tilemaplayer, coord)
	
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.position = tilemaplayer.map_to_local(coord)
	if texture.get_height() > 600:
		sprite.position.y -= 60
	sprite.scale = Vector2(1, 1)
	sprite.name = "SpriteToTween"
	add_child(sprite, true)
	
	$TileMapLayer.set_cell(coord, -1, Vector2i(0,0))

	var tween: Tween = create_tween()
	tween.parallel().tween_property($SpriteToTween, "scale", Vector2(0,0), 0.5).set_trans(Tween.TRANS_SPRING)
	tween.parallel().tween_property($SpriteToTween, "modulate:a", 0, 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback($SpriteToTween.queue_free)
	tween.tween_callback(tween_in_tile.bind(coord))
	sprite.name = "TweeningSprite"
	
func get_cell_texture(tilemaplayer: TileMapLayer, coord: Vector2i) -> Texture:
	var cell_id: int = tilemaplayer.get_cell_source_id(coord)
	var source: TileSetAtlasSource = tilemaplayer.tile_set.get_source(cell_id) as TileSetAtlasSource
	
	var img: Image = source.texture.get_image()
	
	return ImageTexture.create_from_image(img)

func tween_tilemap(old_terrain: Array, new_terrain: Array) -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			var old_tile : WorldTile = old_terrain[i][j]
			var new_tile : WorldTile = new_terrain[i][j]
			if old_tile.type == new_tile.type and old_tile.render_tier == new_tile.render_tier: 
				continue
			tween_out_tile(Vector2i(i, j))
			
	
func get_terrain_copy() -> Array:
	var ar: Array = []
	for i in range(ENV_SIZE):
		var row: Array[WorldTile] = []
		for j in range(ENV_SIZE):
			row.append(WorldTile.new(terrain[i][j].type, terrain[i][j].tier, terrain[i][j].render_tier))
		ar.append(row)
	return ar	

func tween_in_tile(coord: Vector2i) -> void:
	var tilemaplayer: TileMapLayer = $TileMapLayer
	
	var source: TileSetAtlasSource = tilemaplayer.tile_set.get_source(get_tile_source_id(terrain[coord.x][coord.y])) as TileSetAtlasSource
	
	var img: Image = source.texture.get_image()
	
	var texture: Texture = ImageTexture.create_from_image(img)
	
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.position = tilemaplayer.map_to_local(coord)
	if texture.get_height() > 600:
		sprite.position.y -= 100
	else:
		sprite.position.y -= 40
	sprite.scale = Vector2(0, 0)
	sprite.name = "SpriteToTween"
	sprite.modulate.a = 0
	add_child(sprite, true)

	var tween: Tween = create_tween()
	tween.parallel().tween_property($SpriteToTween, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_SPRING)
	tween.parallel().tween_property($SpriteToTween, "modulate:a", 1, 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback($SpriteToTween.queue_free)
	tween.tween_callback($TileMapLayer.set_cell.bind(Vector2i(0,0)).bind(get_tile_source_id(terrain[coord.x][coord.y])).bind(coord))
	sprite.name = "TweeningSprite"

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
			update_render_tier(Vector2i(i,j))

func get_friends_count(coord : Vector2i) -> int:
	var neigh_coords : Array[Vector2i] = $TileMapLayer.get_surrounding_cells(coord)
	var cur_type : G.TileTypes = terrain[coord.x][coord.y].type
	var friends_count : int = 0
	
	# detect neighboring tiles with same type
	for neigh in neigh_coords:
		if not is_valid_map_pos(neigh):
			continue
		if terrain[neigh.x][neigh.y].type == cur_type:
			friends_count += 1
	return friends_count

func update_tile_tier(coord : Vector2i) -> void:
	terrain[coord.x][coord.y].tier = calculate_tier(get_friends_count(coord),terrain[coord.x][coord.y])

func update_render_tier(coord : Vector2i) -> void:
	terrain[coord.x][coord.y].render_tier = calculate_render_tier(get_friends_count(coord),terrain[coord.x][coord.y])

func calculate_render_tier(friends_count : int, tile : WorldTile) -> G.TileTier:
	if tile.type == G.TileTypes.WATER:
		if friends_count < 1:
			return G.TileTier.LOW
		elif friends_count < 4:
			return G.TileTier.MEDIUM
		else:
			return G.TileTier.HIGH
	elif tile.type == G.TileTypes.DESERT:
		if friends_count < 3:
			return G.TileTier.LOW
		elif friends_count < 4:
			return G.TileTier.MEDIUM
		else:
			return G.TileTier.HIGH
	else:
		if friends_count < 3:
			return G.TileTier.LOW
		elif friends_count < 4:
			return G.TileTier.MEDIUM
		else:
			return G.TileTier.HIGH	

func calculate_tier(friends_count : int, tile : WorldTile) -> G.TileTier:
	if friends_count < 3:
		return G.TileTier.LOW
	elif friends_count < 4:
		return G.TileTier.MEDIUM
	else:
		return G.TileTier.HIGH	

func get_tile_source_id(tile : WorldTile) -> int:
	return tile.type * type_modulo + tile.render_tier * tier_modulo
	
