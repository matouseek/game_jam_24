extends Node


@onready var env: Node2D = $Environment

const MAX_ROUNDS : int = 10
var round_num : int = 0
const ZOOM_COEF = 1.25
const CAM_SPEED = 2200
var limit_camera = true
const ZOOM_FACTOR_MAX = 1.75
const ZOOM_FACTOR_MIN = 0.125
var zoom_factor = 0.25
var sfx = 0
var music = 0
@onready var camera = $Environment/Camera2D
const TRANS_TIME = 1


func _ready() -> void:
	HUD.do_will.connect(_on_will_done)
	camera.zoom = Vector2(zoom_factor,zoom_factor)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Environment/Camera2D, "position", Vector2(500,3000),TRANS_TIME).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Environment/Camera2D, "zoom", Vector2(0.2,0.2),TRANS_TIME).set_trans(Tween.TRANS_CUBIC)
	HUD.visible = true
	$Environment.visible = true
	AS.play_music("res://assets/Sounds/game_placeholder.mp3")

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("zoom_in")):
		zoom_factor = min(zoom_factor*ZOOM_COEF,ZOOM_FACTOR_MAX)
		camera.zoom = Vector2(zoom_factor,zoom_factor)
	if (event.is_action_pressed("zoom_out")):
		zoom_factor = max(zoom_factor/ZOOM_COEF,ZOOM_FACTOR_MIN)
		camera.zoom = Vector2(zoom_factor,zoom_factor)

func _process(delta: float) -> void:
	var dir = Vector2(Input.get_action_strength("right")-Input.get_action_strength("left"),
	Input.get_action_strength("down")-Input.get_action_strength("up"))
	dir = dir.normalized()
	camera.position += (CAM_SPEED/zoom_factor)*delta*dir
	
	
func _on_will_done() -> void:
	
	var terrain_copy: Array = env.get_terrain_copy()
	
	PS.is_player_turn = false
	HUD.set_will_be_done_visibility(false)

	print("Process player selection")
	process_used_effects()
	
	if not env.used_effects.is_empty():
		env.tween_tilemap(terrain_copy, env.terrain)
		await get_tree().create_timer(2.0).timeout
	
	terrain_copy = env.get_terrain_copy()
	
	print("Process fuck ups")
	process_fuck_ups()
	
	if not env.fuck_up_effects.is_empty():
		env.tween_tilemap(terrain_copy, env.terrain)
		await get_tree().create_timer(2.0).timeout

	env.calc_distribution()
	update_round_count()
	
	env.clear_effects_visuals()
	
	print("Clear board")
	env.reset_effects()
	
	print("Add fuck ups for next round")
	add_fuck_ups()
	# now wait for player to make selection and then press will be done
	
	HUD.set_will_be_done_visibility(true)
	PS.reset_player_actions_amount()
	PS.is_player_turn = true

func update_round_count() -> void:
	round_num += 1
	HUD.update_round_label(round_num)

func add_fuck_ups() -> void:
	var new_fuck_ups : Array[PlacedEffect] = []
	var fuck_up_amount = 3
	for i in range(fuck_up_amount):
		var pos : Vector2i = env.get_random_map_coord()
		new_fuck_ups.append(PlacedEffect.new(pos,PS.get_rand_effect_type()))
	env.fuck_up_effects = new_fuck_ups
	env.render_all_effects()

func process_fuck_ups() -> void:
	for fuck_up_effect in env.fuck_up_effects:
		process_effect(fuck_up_effect)

func process_used_effects() -> void:
	for used_effect in env.used_effects:
		process_effect(used_effect)


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
	
	var max_amount: int = amounts.max()
	var max_index: int = amounts.find(max_amount)
	var resulting_tile: G.TileTypes = max_index
	
	for i in range(3):
		for j in range(3):
			# Check if tile is on grid
			var current_tile : Vector2i = start_tile + Vector2i(i,j)
			if not env.is_valid_map_pos(current_tile):
				continue
			env.terrain[current_tile.x][current_tile.y].type = resulting_tile
