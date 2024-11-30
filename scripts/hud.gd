extends CanvasLayer
var MAX_SHARE = 0.5
signal do_will

@onready var goals_nodes = {
	G.TileTypes.WATER : $Goals/Water/Sprite2D,
	G.TileTypes.MEADOW :  $Goals/Meadow/Sprite2D,
	G.TileTypes.DESERT :  $Goals/Desert/Sprite2D
}

@onready var progress_nodes = {
	G.TileTypes.WATER : $Goals/Water/ProgressBar,
	G.TileTypes.MEADOW :  $Goals/Meadow/ProgressBar,
	G.TileTypes.DESERT :  $Goals/Desert/ProgressBar
}



func _ready() -> void:
	#update_hud()
	$ItemList.select(0)

func set_goal(type: G.TileTypes, value:float):
	var sprite = goals_nodes[type]
	print(sprite.position)
	sprite.position.x = 44 + int(190*(value/MAX_SHARE))

func update_progress(vals):
	for i in range(len(vals)):
		print(vals[i]*100)
		progress_nodes[i].value = vals[i]*100

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	PS.update_state(index)

func _on_will_be_done_pressed() -> void:
	do_will.emit()

func update_round_label(val : int) -> void:
	$RoundLabel.text = "Round: " + str(val)
