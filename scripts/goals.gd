extends Node2D

enum TileTypes {
	WATER,
	MEADOW,
	DESERT
}

var goals = {}

func _ready() -> void:
	var sum = 0
	var val = randf_range(0.25,0.45)
	goals[TileTypes.DESERT] = val
	HUD.set_goal(TileTypes.DESERT,val)
	sum+=val
	val = randf_range(0.25,0.45)
	goals[TileTypes.MEADOW] = val
	HUD.set_goal(TileTypes.MEADOW,val)
	sum+= val
	goals[TileTypes.WATER] = 1-sum
	HUD.set_goal(TileTypes.WATER,1-sum)
	print(goals)
