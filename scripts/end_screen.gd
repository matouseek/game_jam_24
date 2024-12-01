extends CanvasLayer

@onready var text = $Label

func won(score):
	init()
	text.text = "SKIBIDI WIN"
	
func lost(score):
	init()
	text.text = "OHIO LOSE"


func init():
	HUD.visible = false
	AS.process_mode = Node.PROCESS_MODE_DISABLED
	visible = true
	get_tree().paused = true


func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	AS.process_mode = Node.PROCESS_MODE_ALWAYS
	AS.hide_mm()