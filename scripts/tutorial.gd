extends CanvasLayer
var step = 1
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("mouse_click")):
		if (step == 1):
			HUD.first_step()
		elif (step == 2):
			HUD.second_step()
		elif (step == 3):
			HUD.second_first_step()
		elif (step == 4):
			HUD.second_second_step()
		elif (step == 5):
			HUD.third_step()
		elif (step == 6):
			HUD.last_step()
			get_tree().paused = false
			PS.tutorial = false
			process_mode = Node.PROCESS_MODE_DISABLED
			AS.process_mode = Node.PROCESS_MODE_ALWAYS
		step+=1
