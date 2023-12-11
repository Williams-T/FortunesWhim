extends TextureRect

signal game_finished(results)
var final_results = []

var reelScene = preload("res://reel.tscn")
@onready var box = $HBoxContainer
@onready var time = $arm/Timer
@onready var arm = $arm
var reels = []
var spin_complete_count = 0
var spin_results = []
var spin_delay = 0.1 # Delay in seconds between starting each reel's spin

var fully_spinning = false
var button_pressed = false
var release_pending = false
var spin_timer

func populate_data(data = []):
	# Function to initialize the slot machine with data
	# Assuming 'data' contains reel configurations or other initialization parameters
	if data.size() > 0:
		clear_reels()
		spawn_reels(data)

func start_game():
	# Function to start the slot machine game
	#spin_all_reels()
	pass

func _finished():
	# Determine final results and emit the signal when the game finishes
	final_results = await calculate_final_results()  # Implement this function based on your game logic
	emit_signal("game_finished", final_results)

func calculate_final_results():
	if final_results.size > 0:
		return final_results
	else:
		await get_tree().create_timer(spin_delay).timeout  # Wait before spinning the next reel
		calculate_final_results()

func _ready():
	randomize()

func clear_reels():
	for reel in reels:
		reel.queue_free()
	reels.clear()

func spawn_reels(reel_configs):
	#clear_reels()  # Clear existing reels
	var reel_position = 0  # Starting position for the first reel

	for config in reel_configs:
		var min_value = config[0]
		var max_value = config[1]
		var num_reels
		if config.size() > 2:
			num_reels = config[2]
		else:
			num_reels = 1  # Default to 1 reel if not specified

		for i in range(num_reels):
			var reel = reelScene.instantiate()
			reel.minValue = min_value
			reel.maxValue = max_value
			box.add_child(reel)
			reel.position = Vector2(reel_position * 100, 0)  # Position reels horizontally
			reels.append(reel)
			reel_position += 1
			reel.updateNumbers(reel.maxValue)
	var max_total_width = 400.0  # Maximum total width for all reels (example value)
	var standard_reel_width = 113.0  # Width of a single reel at scale 1.0 (example value)
	var scale_modifier = 1.0  # Default scale

	# Calculate required scale based on the number of reels
	var required_width = reels.size() * standard_reel_width
	if required_width > max_total_width:
		scale_modifier = max_total_width / required_width

# Apply the scale to the container holding the reels
	box.scale = Vector2(scale_modifier, scale_modifier)

func spin_all_reels(style = 0):
	spin_complete_count = 0
	spin_results = []
	final_results = []

	for reel in reels:
		reel.connect("spin_completed", Callable(self, "_on_reel_spin_completed"))
		if style == 0:
			reel.spin()
		elif style == 1:
			reel.spin_infinite(spin_delay)
		elif style == 2:
			print("style 2")
			pass
		await get_tree().create_timer(spin_delay).timeout  # Wait before spinning the next reel
	fully_spinning = true
	# Wait for all reels to complete
	while spin_complete_count < reels.size():
		await get_tree().process_frame

	# Disconnect signals after completion
	for reel in reels:
		reel.disconnect("spin_completed", Callable(self, "_on_reel_spin_completed"))

	final_results = spin_results
	return spin_results

func get_spin_results():
	return final_results

func _on_reel_spin_completed(result):
	spin_results.append(result)
	spin_complete_count += 1
# Example usage
func _process(delta):
	if Input.is_action_just_pressed("up"):
		clear_reels()
		spawn_reels([
			[1, 6, 3], # optimal quantity 4 - 10,
			[1, 20, 2],
			[1, 99, 3],
			[-9, 9, 1]
		]) # Spawn 3 D6 reels
	if Input.is_action_just_pressed("down"):
		spin_all_reels() # Spin all reels
		pass

func _on_arm_button_down():
	button_pressed = true
	release_pending = false
	time.start()  # Start the timer when the button is pressed
	spin_all_reels(1)
	pass # Replace with function body.

func stop_reels():
	var id = 1.0
	for reel in reels:
		reel.stop_button_cycle(id, spin_delay)
		id += 1.0
	pass # Replace with function body.

func _on_arm_button_up():
	if time.time_left > 0:
		# If the timer is still running, mark the release as pending
		release_pending = true
		
	else:
		# If the timer has already finished, reset the button state
		button_pressed = false
		stop_reels()


func _on_timer_timeout():
	if release_pending:
		# If the button was released during the 2-second period, reset the button state
		button_pressed = false
		var id = 1.0
		for reel in reels:
			reel.stop_button_cycle(id, spin_delay)
			id += 1.0
