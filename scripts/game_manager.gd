extends Node

const MAX_ROUNDS : int = 10
var round_num : int = 0

func _ready() -> void:
	HUD.do_will.connect(_on_will_done)
	
func _on_will_done() -> void:
	
	PS.is_player_turn = false
	

	
	print("Process fuck ups")
	process_fuck_ups()
	
	await get_tree().create_timer(1.0).timeout
	
	print("Process player selection")
	process_used_effects()
	
	update_round_count()
	
	await get_tree().create_timer(1.0).timeout
	
	print("Clear board")
	reset_map_effects()
	
	print("Add fuck ups for next round")
	add_fuck_ups()
	# now wait for player to make selection and then press will be done

func update_round_count() -> void:
	round_num += 1
	HUD.update_round_label(round_num)
	
func reset_map_effects() -> void:
	$Environment.fuck_up_effects.clear()
	$Environment.used_effects.clear()
	$Environment.render_all_effects()

func add_fuck_ups() -> void:
	var new_fuck_ups : Array[PlacedEffect] = []
	var fuck_up_amount = 3
	for i in range(fuck_up_amount):
		var pos : Vector2i = $Environment.get_random_map_coord()
		new_fuck_ups.append(PlacedEffect.new(pos,PS.get_rand_effect_type()))
	$Environment.fuck_up_effects = new_fuck_ups
	$Environment.render_all_effects()
	print("Fuck ups placed")

func process_fuck_ups() -> void:
	
	pass


func process_effect(effect : PlacedEffect) -> void:
	match effect.type:
		PS.PlayerEffects.RAIN:
			process_rain()
		PS.PlayerEffects.DRAUGHT:
			process_draught()
		PS.PlayerEffects.MAJORITY:
			process_majority()

func process_used_effects() -> void:
	for effect in $Environment.used_effects:
		effect.print()
		process_effect(effect)

func process_rain() -> void:
	print("Processing rain")
	
func process_draught() -> void:
	print("Processing draught")
	
func process_majority() -> void:
	print("Processing majority")
