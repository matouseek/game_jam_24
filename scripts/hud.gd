extends CanvasLayer

@onready var action_nodes = {
	PS.PlayerEffects.RAIN : $Actions/Rain/Sprite2D,
	PS.PlayerEffects.DRAUGHT : $Actions/Draught/Sprite2D,
	PS.PlayerEffects.MAJORITY : $Actions/Majority/Sprite2D
}

func _ready() -> void:
	update_hud()

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


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	reset_hud()
	PS.update_state(index)
	update_hud()
