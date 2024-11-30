extends Node2D

const ENV_SIZE: int = 12

enum TileTypes {
	WATER,
	MEADOW,
	DESERT
}

var terrain: Array = []

func _ready() -> void:
	for i in range(ENV_SIZE):
		var row: Array = []
		for j in range(ENV_SIZE):
			row.append(TileTypes.MEADOW)
		terrain.append(row)
	initialize_randomly()
	set_map()
	calc_distribution()
	
	
	
func _input(event):
	if event is InputEventMouseButton:
		var pos = $TileMapLayer.local_to_map(get_local_mouse_position())
		$TileMapLayer.set_cell(pos,0,Vector2i(0,0))
		terrain[pos.x][pos.y] = 0
		calc_distribution()
		
		

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

func initialize_randomly() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			terrain[i][j] = randi_range(0,2)
	pass

func set_map() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			$TileMapLayer.set_cell(Vector2i(i,j),terrain[i][j],Vector2i(0,0))
