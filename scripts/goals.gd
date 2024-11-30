extends Node2D

enum TileTypes {
	WATER,
	MEADOW,
	DESERT
}

func _ready() -> void:
	var sum = 0
	var vals = []
	var val = 0
	for x in range(len(TileTypes)):
		val = randf_range(0.25,0.45)
		vals.append(val)
		sum += val
	for type in TileTypes.values():
		HUD.set_goal(type,vals[type]/sum)
