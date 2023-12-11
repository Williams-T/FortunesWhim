extends TextureRect

signal game_finished(results)
var final_results

func instantiate(data = []):
	pass

func start_game():
	pass

func _finished():
	# Emit the signal when the game finishes
	emit_signal("game_finished", final_results)
