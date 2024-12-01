extends CanvasLayer

var sfx = 0
var music = 0
var show = false

func _ready() -> void:
	$SFX.value = sfx
	$Music.value = music

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("settings") and get_tree().current_scene.name != 'Menu'):
		visible = !visible
		HUD.visible = !HUD.visible
		get_tree().paused = !get_tree().paused


func _on_sfx_value_changed(value: float) -> void:
	sfx = value
	$SFXPlayer.volume_db = sfx

func _on_music_value_changed(value: float) -> void:
	music = value
	$MusicPlayer.volume_db = music
	
func play_music(name):
	$MusicPlayer.stream = load(name) as AudioStream
	$MusicPlayer.stream.loop = true
	$MusicPlayer.play()


func _on_back_pressed() -> void:
	if (get_tree().current_scene.name == 'Menu'):
		get_tree().current_scene.visible = true
		visible = false
	else:
		visible = !visible
		HUD.visible = !HUD.visible
		get_tree().paused = !get_tree().paused
		


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	visible = false
	get_tree().paused = false


func _on_color_picker_button_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _on_default_background_pressed() -> void:
	$ColorPickerButton.color = Color("d6f1eb")
	RenderingServer.set_default_clear_color(Color("d6f1eb"))


func _on_background_pressed() -> void:
	$ColorPickerButton.get_popup().visible = !show
	show = !show
	
