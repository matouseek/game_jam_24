extends Node

func _ready() -> void:
	HUD.do_will.connect(_on_will_done)
	
func _on_will_done() -> void:
	PS.is_player_turn = false
	process_used_effects()
	
func process_used_effects() -> void:
	for used_effect in $Environment.used_effects:
		used_effect.print()
		match used_effect.type:
			PS.PlayerEffects.RAIN:
				process_rain()
			PS.PlayerEffects.DRAUGHT:
				process_draught()
			PS.PlayerEffects.MAJORITY:
				process_majority()

func process_rain() -> void:
	print("Processing rain")
	
func process_draught() -> void:
	print("Processing rain")
	
func process_majority() -> void:
	print("Processing rain")
