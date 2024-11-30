extends Node2D

const ENV_SIZE: int = 12
var last_pos = [Vector2i(-1000,-1000)]

var offsets = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),               Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)]

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
	if (event is InputEventMouse):
		var pos = $TileMapLayer.local_to_map(get_local_mouse_position())
		if (pos.x >= 0 and pos.x < ENV_SIZE and pos.y >= 0 and pos.y<ENV_SIZE):
			if event.is_action_pressed("mouse_click"):
				for lpos in last_pos:
					$TileMapLayer.set_cell(lpos,2,Vector2i(0,0))
			if (last_pos != null):
				for lpos in last_pos:
					$Highlight.set_cell(lpos,-1,Vector2i(0,0))
			last_pos = [pos]
			$Highlight.set_cell(pos,0,Vector2i(0,0))
			if (PS.PlayerEffects.MAJORITY == PS.selected_effect):
				for offset in offsets:
					var newpos = pos+offset
					if (newpos.x >= 0 and newpos.x < ENV_SIZE and newpos.y >= 0 and newpos.y<ENV_SIZE):
						last_pos.append(newpos)
						$Highlight.set_cell(newpos,0,Vector2i(0,0))
	

func initialize_randomly() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			terrain[i][j] = randi_range(0,1)
	pass

func set_map() -> void:
	for i in range(ENV_SIZE):
		for j in range(ENV_SIZE):
			#print("Setting cell to",terrain[i][j])
			$TileMapLayer.set_cell(Vector2i(i,j),terrain[i][j],Vector2i(0,0))

func get_tile_id(type : TileTypes) -> int:
	if type == TileTypes.DESERT:
		return 0
	elif type == TileTypes.MEADOW:
		return 4
	elif type == TileTypes.WATER:
		return 5
	else:
		return -1
