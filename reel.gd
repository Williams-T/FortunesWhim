extends TextureRect
class_name Reel
var is_spinning = false
var stop_button_pressed = false
signal spin_completed(result)
@onready var hbox = $VBoxContainer/HBoxContainer

var numbers = [
	preload("res://_working/numbers/0.png"), 
	preload("res://_working/numbers/1.png"), 
	preload("res://_working/numbers/2.png"), 
	preload("res://_working/numbers/3.png"), 
	preload("res://_working/numbers/4.png"), 
	preload("res://_working/numbers/5.png"), 
	preload("res://_working/numbers/6.png"), 
	preload("res://_working/numbers/7.png"), 
	preload("res://_working/numbers/8.png"), 
	preload("res://_working/numbers/9.png"),
	preload("res://_working/numbers/minus.png")]

var specials = [
	preload("res://_working/specials/cash.png"),
	preload("res://_working/specials/heart.png"),
	preload("res://_working/specials/shield.png"),
	preload("res://_working/specials/skull.png"),
	preload("res://_working/specials/sword.png")
]

var minValue: int = 1
var maxValue: int = 6
var result: int = 0

func spin_infinite(delay):
	var spin_duration = 1.1  # Total duration of the spin
	var spin_steps = 100  # Number of intermediate steps
	var step_delay = spin_duration / spin_steps
	var random_number = randi() % (maxValue - minValue + 1) + minValue
	while(stop_button_pressed == false):
		is_spinning = true
		random_number = randi() % (maxValue - minValue + 1) + minValue
		updateNumbers(random_number, true)
		await get_tree().create_timer(step_delay).timeout
	is_spinning = false
	stop_button_pressed = false
	updateNumbers(random_number)
	emit_signal("spin_completed", random_number)
	return random_number
func spin():
	is_spinning = true
	var spin_duration = 1.1  # Total duration of the spin
	var spin_steps = 100  # Number of intermediate steps
	var step_delay = spin_duration / spin_steps

	# Spin through random numbers
	for i in range(spin_steps):
		var random_number = randi() % (maxValue - minValue + 1) + minValue
		updateNumbers(random_number, true)
		await get_tree().create_timer(step_delay).timeout

	# Final result
	result = randi() % (maxValue - minValue + 1) + minValue
	updateNumbers(result)
	is_spinning = false
	emit_signal("spin_completed", result)
	return result

func cycleHbox():
	hbox.free()
	hbox = HBoxContainer.new()
	$VBoxContainer.add_child(hbox)
	

func stop_button_cycle(id, delay):
	await get_tree().create_timer(id*(delay - 0.03)).timeout  # Wait before spinning the next reel
	stop_button_pressed = true

func updateNumbers(number : int, jitter := false):
	cycleHbox()
	var num_str = str(number)
	if num_str.length() == 1:
		hbox.add_child(Control.new())
		hbox.add_child(Control.new())
		hbox.add_child(Control.new())
	if num_str.length() == 2:
		hbox.add_child(Control.new())
		hbox.add_child(Control.new())
	else:
		hbox.add_child(Control.new())
	
	for i in num_str:
		var rect = TextureRect.new()
		if i == '-':
			rect.texture = numbers[10]
		else:
			rect.texture = numbers[int(i)]
		rect.custom_minimum_size = Vector2(30,222)
		if jitter:
			rect.custom_minimum_size = Vector2(30, randi()%300+100)
			rect.position += Vector2(0, randi()%300-150)
			pass
		else:
			rect.offset_top = 100
			rect.offset_bottom = 100
			
		hbox.add_child(rect)
	hbox.add_child(Control.new())
