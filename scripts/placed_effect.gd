extends Object

class_name PlacedEffect

static var count : int = 0

var id : int
var source_coord : Vector2i
var type : PS.PlayerEffects

func _init( source_coord : Vector2i, type : PS.PlayerEffects):
	self.id = count
	count += 1
	self.source_coord = source_coord
	self.type = type

func print():
	print("Id: ",id," Source coord: ",source_coord," Type: ",type)
