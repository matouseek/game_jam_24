extends Node

enum PlayerEffects {
	RAIN,
	DRAUGHT,
	MAJORITY
}

const MAX_ACTIONS_PER_TURN: int = 2
var tutorial = true
var is_player_turn: bool = true
var selected_effect: PlayerEffects = PlayerEffects.RAIN
var remaining_actions: int = MAX_ACTIONS_PER_TURN

func update_state(new_effect: PlayerEffects):
	selected_effect = new_effect
	
func get_rand_effect_type() -> PlayerEffects:
	return randi_range(0,len(PlayerEffects)-1)
	
func update_player_action_amount(val: int) -> void:
	remaining_actions = val
	HUD.update_remaining_actions()
	
func reset_player_actions_amount() -> void:
	update_player_action_amount(MAX_ACTIONS_PER_TURN)
