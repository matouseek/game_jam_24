extends Node

@onready var env: Node2D = $Environment

func _ready() -> void:
	HUD.do_will.connect(_on_will_done)
	
func _on_will_done() -> void:
	PS.is_player_turn = false
	process_used_effects()
	env.set_map()
	env.calc_distribution()
	env.clear_effects_visuals()
	env.reset_effects()
	
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
	var tile: G.TileTypes = env.terrain[rain_effect.source_coord.x][rain_effect.source_coord.y]
	match tile:
		G.TileTypes.DESERT:
			env.terrain[rain_effect.source_coord.x][rain_effect.source_coord.y] = G.TileTypes.MEADOW
		G.TileTypes.MEADOW:
			env.terrain[rain_effect.source_coord.x][rain_effect.source_coord.y] = G.TileTypes.WATER
		G.TileTypes.WATER:
			print("Rained on water")
	
func process_draught(draught_effect: PlacedEffect) -> void:
	var tile: G.TileTypes = env.terrain[draught_effect.source_coord.x][draught_effect.source_coord.y]
	match tile:
		G.TileTypes.DESERT:
			print("Draught on desert")
		G.TileTypes.MEADOW:
			env.terrain[draught_effect.source_coord.x][draught_effect.source_coord.y] = G.TileTypes.DESERT
		G.TileTypes.WATER:
			env.terrain[draught_effect.source_coord.x][draught_effect.source_coord.y] = G.TileTypes.MEADOW
	
func process_majority(majority_effect: PlacedEffect) -> void:
	var amounts: Array[int] = []
	amounts.resize(G.TileTypes.size())
	
	var start_tile: Vector2i = Vector2i(majority_effect.source_coord.x - 1, majority_effect.source_coord.y - 1)
	for i in range(3):
		for j in range(3):
			# Check if tile is on grid
			if start_tile.x < 0 or start_tile.y < 0: continue
			var tile: G.TileTypes = env.terrain[start_tile.x + i][start_tile.y + j]
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
			if start_tile.x < 0 or start_tile.y < 0: continue
			env.terrain[start_tile.x + i][start_tile.y + j] = resulting_tile
	
