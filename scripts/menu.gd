extends Node2D

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_pressed() -> void:
	visible = false
	AS.visible = true


func _on_controls_pressed() -> void:
	var showed = $Label.visible
	$Label.visible = !showed
	$Play.visible = showed
	$Settings.visible = showed
	if (showed):$Controls.text = 'CONTROLS'
	else: $Controls.text = 'BACK'
