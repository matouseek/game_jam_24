extends CanvasLayer

var show = false
const MIN_DB = -20
const MAX_DB = 7

const DEFAULT_BACK_COLOR = "92a8cb";

var sfx = -5
var music = -5
@onready var cp = $Background/CP
@onready var mp = $MusicPlayer
@onready var sp = $SFXPlayer

func _ready() -> void:
	
	$SFX.max_value = MAX_DB
	$Music.max_value = MAX_DB
	$SFX.min_value = MIN_DB
	$Music.min_value = MIN_DB
	$SFX.value = sfx
	$Music.value = music
	cp.color_modes_visible = false
	#play_music("res://assets/Sounds/Background.ogg")

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("settings")):
		$Sprite2D.visible = (get_tree().current_scene.name == 'Menu')
		if (get_tree().current_scene.name == 'Menu' and visible == true):
			visible = false
			get_tree().paused = false
			get_tree().current_scene.visible = true
		elif (get_tree().current_scene.name != 'Menu'):
			visible = !visible
			HUD.visible = !visible
			get_tree().paused = !get_tree().paused
			$MainMenu.visible = true
		cp.visible = false

func _on_sfx_value_changed(value: float) -> void:
	if (value == MIN_DB): sp.stop()
	sfx = value
	sp.volume_db = sfx

func _on_music_value_changed(value: float) -> void:
	if (value == MIN_DB): value = -80
	elif(music == MIN_DB): mp.play()
	music = value
	mp.volume_db = music
	
func play_sfx(name):
		if sfx>MIN_DB:
			sp.stream = load(name) as AudioStream
			sp.play()


func play_music(name):
	if music>MIN_DB:
		mp.stream = load(name) as AudioStream
		mp.stream.loop = true
		mp.play()

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
	$MainMenu.visible = false

func _on_default_background_pressed() -> void:
	cp.color = Color(DEFAULT_BACK_COLOR)
	RenderingServer.set_default_clear_color(Color(DEFAULT_BACK_COLOR))

func _on_background_pressed() -> void:
	cp.visible = !cp.visible

func tutorial():
	$MusicPlayer.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_cp_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)
	
func hide_mm():
	$MainMenu.visible = false
