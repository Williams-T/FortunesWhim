extends Node

var results = []
var finished = 0
var controller_scene
var controller_instance


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func controller(type = 0, data := []):
	controller_scene = _choose_controller(type)
	if str(controller_scene) == "error":
		print("ERROR - Invalid Controller Type.")
		return "error"
	_instantiate_controller(data)
	await _translate_controller()
	while controller_instance.final_results.size() == 0:
		await get_tree().process_frame
	return controller_instance.final_results


func _choose_controller(type):
	# Determines what controller to spawn [ slot machine, roulette, blackjack ]
	var controllers = [
		preload("res://slot_machine.tscn"),
		preload("res://roulette_wheel.tscn"),
		preload("res://black_jack.tscn")
	]
	if type >= 0 and type <= (controllers.size()-1):
		return controllers[type]
	else:
		return "error"


func _instantiate_controller(data):
	# Instantiates chosen controller with proper data offscreen
	var instance = controller_scene.instantiate()
	add_child(instance)
	if instance and instance.has_method("populate_data"):
		if data[0] is Array:
			instance.populate_data(data)
		else:
			instance.populate_data([data])
	instance.position = Vector2(0, -1000) # offscreen
	controller_instance = instance





# Moves the controller onto the screen and waits for interaction results
func _translate_controller():
	var target_position = Vector2(25, 25) + Vector2(randi()%50 - 25, randi()%50 - 25) # Target position on the screen
	controller_instance.position = target_position
	# Connect to the game_finished signal and wait for it
	controller_instance.connect("game_finished", Callable(self, "_on_game_finished"))
	controller_instance.start_game()



func _on_game_finished():
	results = controller_instance.final_results # Store the results
	finished = 1
	controller_instance.disconnect("game_finished", Callable(self, "_on_game_finished"))


func cycle_slot_configs(configs):
# Iterate over the configurations and spawn each slot machine
	for config in configs:
		print("Spawning slot machine with config: ", config)
		await controller(0, config)  # Assuming '0' is the type for slot machines
		# Optionally, introduce a delay or handle the results here
		await finished == 1
		print(controller_instance.final_results)
		finished = 0
		await get_tree().create_timer(1.0).timeout
		for child in get_children():
			child.queue_free()

func test_multiple_slot_machines():
	# Example configurations for different slot machines
	var slot_configs = [
		[1, 6, 3],  # Configuration for first slot machine
		[1, 20, 2],  # Configuration for second slot machine
		[1, 10],  # Configuration for third slot machine
		[ [1, 99, 2] , [1, 10, 2] ], # Hybrid Config
		[ [1, 3], [1,6], [1,9], [1,12], [1,15], [1,18], [1,21], [1,24], [1,27], [1,30], [1,99]]
	]
	cycle_slot_configs(slot_configs)
	
