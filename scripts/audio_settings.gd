extends CanvasLayer

var sfx = 0
var music = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SFX.value = sfx
	$Music.value = music

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("settings")):
		visible = !visible
		HUD.visible = !HUD.visible
		get_tree().paused = !get_tree().paused


func _on_sfx_value_changed(value: float) -> void:
	sfx = value


func _on_music_value_changed(value: float) -> void:
	music = value
