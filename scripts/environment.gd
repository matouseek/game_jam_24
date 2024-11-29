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
