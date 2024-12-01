extends CanvasLayer
var MAX_SHARE = 0.5
signal do_will
var mouse_unlock = true
var first_run = true

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

@onready var error_margin_nodes = {
	G.TileTypes.WATER : $Goals/Water/Sprite2D/ErrorMargin,
	G.TileTypes.MEADOW :  $Goals/Meadow/Sprite2D/ErrorMargin,
	G.TileTypes.DESERT :  $Goals/Desert/Sprite2D/ErrorMargin
}

func zeroth_step():
	$P0.visible = true
	$L0.visible = true

func first_step():
	$P0.visible = false
	$L0.visible = false
	
	$P1.visible = true
	$L1.visible = true

func second_step():
	$P1.visible = false
	$L1.visible = false
	
	$P2.visible = true
	$L2.visible = true
	
func second_first_step():
	$P2.visible = false
	$L2.visible = false
	
	$P21.visible = true
	$L21.visible = true

func second_second_step():
	$P21.visible = false
	$L21.visible = false
	
	$P22.visible = true
	$L22.visible = true

func third_step():
	$P22.visible = false
	$L22.visible = false
	
	$P3.visible = true
	$L3.visible = true

func last_step():
	$P3.visible = false
	$L3.visible = false
	

func _ready() -> void:
	$ItemList.select(0)
	HUD.update_remaining_actions()

func set_goal_hud(type: G.TileTypes, value:float):
	var sprite = goals_nodes[type]
	sprite.position.x = int(200*value)-191

func update_progress_hud(vals):
	for i in range(len(vals)):
		progress_nodes[i].value = vals[i]*100
		

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	PS.update_state(index)

func _on_will_be_done_pressed() -> void:
	do_will.emit()

func update_round_label(val : int) -> void:
	$RoundLabel.text = "Round: " + str(val)
	
func update_remaining_actions() -> void:
	$RemainingActionsLabel.text = "Remaining: " + str(PS.remaining_actions)

func set_error_margins_scale(scale : float) -> void:
	
	for i in range(len(error_margin_nodes)):
		var vertices = error_margin_nodes[i].polygon
		var old_height = vertices[0].y 
		var new_width = 0
		if first_run:
			new_width = vertices[0].x * scale
			if i == 2:
				first_run = false
		else:
			new_width = vertices[0].x
		
		var new_vert = [Vector2(new_width,old_height),Vector2(new_width,-old_height),Vector2(-new_width,-old_height),Vector2(-new_width,old_height)]
		error_margin_nodes[i].polygon = new_vert

func set_will_be_done_visibility(visibility: bool) -> void:
	$WillBeDone.visible = visibility


func _on_item_list_mouse_entered() -> void:
	mouse_unlock = false


func _on_item_list_mouse_exited() -> void:
	mouse_unlock = true


func _on_will_be_done_mouse_entered() -> void:
	mouse_unlock = false


func _on_will_be_done_mouse_exited() -> void:
	mouse_unlock = true
