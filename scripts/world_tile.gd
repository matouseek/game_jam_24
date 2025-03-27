extends Object

class_name WorldTile

static var count : int = 0

var id : int
var type : G.TileTypes
var tier : G.TileTier
var render_tier : G.TileTier

func _init( type : G.TileTypes, tier : G.TileTier, render_tier : G.TileTier):
	self.id = count
	count += 1
	self.type = type
	self.tier = tier
	self.render_tier = render_tier

func print():
	print("(",type,",",tier,")")
	#print("Id: ",id," Type: ",type," Tier: ",tier)
	
func get_str():
	return "(" + str(type) + "," + str(tier) + "," + str(render_tier) + ")"
