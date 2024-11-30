extends Node2D

const ENV_SIZE: int = 12

enum TileTypes {
	DESERT,
	MEADOW,
	WATER
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
	
	
	
func _input(event):
	# Mouse in viewport coordinates.
	
	if event is InputEventMouseButton:
		var pos = $TileMapLayer.local_to_map(get_local_mouse_position())
		print("Position on map",pos)
		#$TileMapLayer.set_cell(pos,4,Vector2i(0,0))
		

func initialize_randomly() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			terrain[i][j] = randi_range(0,2)
	pass

func set_map() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			#print("Setting cell to",terrain[i][j])
			$TileMapLayer.set_cell(Vector2i(i,j),get_tile_id(terrain[i][j]),Vector2i(0,0))

func get_tile_id(type : TileTypes) -> int:
	if type == TileTypes.DESERT:
		return 3
	elif type == TileTypes.MEADOW:
		return 4
	elif type == TileTypes.WATER:
		return 5
	else:
		return -1
