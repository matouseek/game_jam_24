extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_water_pressed() -> void:
	print("water")


func _on_draught_pressed() -> void:
	print("draught")


func _on_majority_pressed() -> void:
	print("majority")
