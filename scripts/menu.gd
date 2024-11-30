extends Node2D

func _ready() -> void:
	AS.play_music("res://assets/Sounds/menu.mp3")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_pressed() -> void:
	visible = false
	AS.visible = true
