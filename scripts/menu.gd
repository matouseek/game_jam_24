extends Node2D
	
func _on_button_pressed() -> void:
	$Trans.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($Trans, "color:a", 1, 1)
	tween.tween_callback(fade_in)
	
func fade_in():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
