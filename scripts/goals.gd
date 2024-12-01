extends Node2D

# bigger difference -> harder game
const GOAL_DISTR_REL_LOW_BOUND = 10 
const GOAL_DISTR_REL_UP_BOUND = 20

const GOAL_DISTR_SELECTION_SIZE = 10 # bigger -> harder game

const GOAL_ERROR_MARGIN : float = 0.1 # absolute in percents distance

var current_percentages : Array[float] = [0.0,0.0,0.0]
var goal_percentages : Array[float] = [0.0,0.0,0.0]

enum TileTypes {
	WATER,
	MEADOW,
	DESERT
}

enum TileTier {
	LOW,
	MEDIUM,
	HIGH
}

func calculate_mse(distribution1: Array, distribution2: Array) -> float:
	var mse = 0.0
	for i in range(len(distribution1)):
		mse += absf(distribution1[i] - distribution2[i])
	return mse / len(distribution1)

func get_random_distribs(amount : int, distr_size : int) -> Array:
	var distribs = []
	for i in range(amount):
		# generate distribution
		var distribution : Array[float] = [0.0,0.0,0.0]
		for j in range(distr_size):
			distribution[j] = randi_range(GOAL_DISTR_REL_LOW_BOUND,GOAL_DISTR_REL_UP_BOUND)
		normalize(distribution)
		distribs.append(distribution)
	return distribs
			
		
func normalize(arr : Array[float]) -> void:
	var sum : float = 0 # normalize
	for i in range(len(arr)):
		sum += arr[i]
	for i in range(len(arr)):
		arr[i] /= sum

func argmax(arr : Array[float]) -> int:
	var max_index : float = 0
	for i in range(len(arr)):
		if arr[i] > arr[max_index]:
			max_index = i
	return max_index

func set_goals_distribution(current_dist : Array[float]) -> void:
	
	var distributions : Array = get_random_distribs(GOAL_DISTR_SELECTION_SIZE,len(current_dist))
	var mses : Array[float] = []
	
	for distribution in distributions:
		mses.append(calculate_mse(distribution,current_dist))
	
	var max_mse_index : int = argmax(mses)
	
	goal_percentages = distributions[max_mse_index]
	
	for type in TileTypes.values():
		HUD.set_goal_hud(type,goal_percentages[type])
	HUD.set_error_margins_scale(GOAL_ERROR_MARGIN*2)
	

func update_progress(vals):
	for i in range(len(vals)):
		current_percentages[i] = vals[i]
	HUD.update_progress_hud(current_percentages)

func _ready() -> void:
	pass
		
func get_rand_tile_type() -> TileTypes:
	return randi_range(0,len(TileTypes)-1)
	
