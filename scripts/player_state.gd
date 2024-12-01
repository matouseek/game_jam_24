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
	
func get_rand_effect_type(prob_distr : Array[float]) -> PlayerEffects:
	var rand_pick : float = randf()
	for i in range(len(prob_distr)):
		rand_pick -= prob_distr[i]
		if rand_pick <= 0:
			return i
	return len(prob_distr) - 1
	
func update_player_action_amount(val: int) -> void:
	remaining_actions = val
	HUD.update_remaining_actions()
	
func reset_player_actions_amount() -> void:
	update_player_action_amount(MAX_ACTIONS_PER_TURN)
