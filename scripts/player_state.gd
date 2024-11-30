extends Node

enum PlayerEffects {
	RAIN,
	DRAUGHT,
	MAJORITY
}

var is_player_turn: bool = true
var selected_effect: PlayerEffects = PlayerEffects.RAIN

func update_state(new_effect: PlayerEffects):
	selected_effect = new_effect
	
func get_rand_effect_type() -> PlayerEffects:
	return randi_range(0,len(PlayerEffects)-1)
