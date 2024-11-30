extends Node2D

var percentages : Array[float] = [0.0,0.0,0.0]
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
	var max_val : int = 20
	var min_val : int = 10
	var distribs = []
	for i in range(amount):
		# generate distribution
		var distribution : Array[float] = [0.0,0.0,0.0]
		for j in range(distr_size):
			distribution[j] = randi_range(min_val,max_val)
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
	var distr_amount : int = 10
	
	var distributions : Array = get_random_distribs(distr_amount,len(current_dist))
	var mses : Array[float] = []
	
	for distribution in distributions:
		mses.append(calculate_mse(distribution,current_dist))
	
	var max_mse_index : int = argmax(mses)
	
	goal_percentages = distributions[max_mse_index]
	
	for type in TileTypes.values():
		HUD.set_goal_hud(type,goal_percentages[type])
	

func update_progress(vals):
	for i in range(len(vals)):
		percentages[i] = vals[i]
	HUD.update_progress_hud(percentages)

func _ready() -> void:
	pass
		
func get_rand_tile_type() -> TileTypes:
	return randi_range(0,len(TileTypes)-1)
	
