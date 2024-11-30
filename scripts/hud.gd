extends CanvasLayer
var MAX_SHARE = 0.5

signal do_will

@onready var action_nodes = {
	PS.PlayerEffects.RAIN : $Actions/Rain/Sprite2D,
	PS.PlayerEffects.DRAUGHT : $Actions/Draught/Sprite2D,
	PS.PlayerEffects.MAJORITY : $Actions/Majority/Sprite2D
}

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
	update_hud()
	$ItemList.select(0)

func _on_rain_pressed() -> void:
	reset_hud()
	PS.update_state(PS.PlayerEffects.RAIN)
	update_hud()

func _on_draught_pressed() -> void:
	reset_hud()
	PS.update_state(PS.PlayerEffects.DRAUGHT)
	update_hud()


func _on_majority_pressed() -> void:
	reset_hud()
	PS.update_state(PS.PlayerEffects.MAJORITY)
	update_hud()
	

func update_hud():
	action_nodes[PS.selected_effect].modulate = Color(1, 0, 0)
	
func reset_hud():
	action_nodes[PS.selected_effect].modulate = Color(1, 1, 1)

func set_goal(type: G.TileTypes, value:float):
	var sprite = goals_nodes[type]
	print(sprite.position)
	sprite.position.x = 44 + int(190*(value/MAX_SHARE))
	
func update_progress(vals):
	for i in range(len(vals)):
		print(vals[i]*100)
		progress_nodes[i].value = vals[i]*100

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	reset_hud()
	PS.update_state(index)
	update_hud()


func _on_will_be_done_pressed() -> void:
	do_will.emit()
