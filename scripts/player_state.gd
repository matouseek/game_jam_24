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
