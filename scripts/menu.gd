extends Node2D
@onready var label = $Label
@onready var button = $Controls
func _on_button_pressed() -> void:
	Clouds.visible = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_pressed() -> void:
	visible = false
	AS.visible = true


func _on_controls_pressed() -> void:
	var showed = label.visible
	if (showed): AS.process_mode = Node.PROCESS_MODE_ALWAYS
	else: AS.process_mode = Node.PROCESS_MODE_DISABLED
	label.visible = !showed
	$Play.visible = showed
	$Settings.visible = showed
	$Exit.visible = showed
	if (showed):button.text = 'CONTROLS'
	else: button.text = 'BACK'

func _input(event: InputEvent) -> void:
	if (label.visible and event.is_action_pressed("settings")):
		var showed = label.visible
		if (showed): AS.process_mode = Node.PROCESS_MODE_ALWAYS
		else: AS.process_mode = Node.PROCESS_MODE_DISABLED
		label.visible = !showed
		$Play.visible = showed
		$Settings.visible = showed
		if (showed):button.text = 'CONTROLS'
		else: button.text = 'BACK'
		


func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
