extends Object

class_name WorldTile

enum Tier {
	LOW,
	MEDIUM,
	HIGH
}

static var count : int = 0

var id : int
var type : G.TileTypes
var tier : Tier

func _init( type : G.TileTypes, tier : Tier):
	self.id = count
	count += 1
	self.type = type
	self.tier = tier

func print():
	print("Id: ",id," Type: ",type," Tier: ",tier)
