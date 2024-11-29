extends Node

enum PlayerEffects {
	RAIN,
	DRAUGHT,
	MAJORITY
}

var selected_effect: PlayerEffects = PlayerEffects.RAIN

func update_state(new_effect: PlayerEffects):
	selected_effect = new_effect
