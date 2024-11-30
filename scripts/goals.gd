extends Node2D

enum TileTypes {
	WATER,
	MEADOW,
	DESERT
}

var goals = {}

func _ready() -> void:
	var sum = 0
	var val = 0
	for type in TileTypes.values():
		val = randf_range(0.25,0.45)
		goals[type] = val
		HUD.set_goal(type,val)
		sum+=val
	val =  1-(sum-val)
	goals[TileTypes.WATER] = val
	HUD.set_goal(TileTypes.WATER,val)
	print(goals)
