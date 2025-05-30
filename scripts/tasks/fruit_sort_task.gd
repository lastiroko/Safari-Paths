extends Control
signal task_completed(points_awarded: int, was_correct: bool)

@onready var grid := $Grid
@onready var instruction := $InstructionLabel

var all_fruits := [
	{ "name": "Appleg", "quality": "good" },
	{ "name": "Bananab", "quality": "bad" },
	{ "name": "Dragonfruitg", "quality": "good" },
	{ "name": "Pearb", "quality": "bad" },
	{ "name": "Pineappleg", "quality": "good" },
	{ "name": "Orangeb", "quality": "bad" },
	{ "name": "Grapesg", "quality": "good" },
	{ "name": "Plumb", "quality": "bad" },
	{ "name": "Strawberryg", "quality": "good" },
	{ "name": "Mangob", "quality": "bad" },
	{ "name": "Kiwig", "quality": "good" },
	{ "name": "Guavab", "quality": "bad" },
	{ "name": "Papayag", "quality": "good" },
	{ "name": "Figb", "quality": "bad" },
	{ "name": "Watermelong", "quality": "good" }
]

# This array will store the 6 fruit dictionaries currently assigned to the grid buttons.
# Each dictionary will have a 'name', 'quality', and 'is_picked' status.
var current_grid_fruits: Array[Dictionary] = [] 
var picked_good_fruits_count := 0 # Tracks how many good fruits have been successfully picked
var task_finished := false

func _ready():
	randomize()
	instruction.text = "🍎 Pick the ripe fruits!"
	initialize_grid_with_fruits() # Initial call to populate the grid

func initialize_grid_with_fruits():
	# This function is called only at the very start of the task.
	# It populates current_grid_fruits with 6 initial fruits, ensuring 3 good ones.
	
	current_grid_fruits.clear()
	var temp_all_fruits = all_fruits.duplicate()
	temp_all_fruits.shuffle()

	var good_fruits_added_to_initial_set = 0
	var initial_fruits_temp: Array[Dictionary] = []

	# First, try to get 3 good fruits and 3 bad fruits for the initial display
	var good_candidates = temp_all_fruits.filter(func(f): return f["quality"] == "good")
	var bad_candidates = temp_all_fruits.filter(func(f): return f["quality"] == "bad")

	# Add 3 good fruits
	for i in range(min(3, good_candidates.size())):
		var fruit = good_candidates[i].duplicate()
		fruit["is_picked"] = false
		initial_fruits_temp.append(fruit)
		good_fruits_added_to_initial_set += 1

	# Add remaining fruits to fill up to 6, prioritizing bad fruits
	var remaining_slots = 6 - initial_fruits_temp.size()
	var combined_remaining = bad_candidates + good_candidates.slice(good_fruits_added_to_initial_set)
	combined_remaining.shuffle()

	for i in range(min(remaining_slots, combined_remaining.size())):
		var fruit = combined_remaining[i].duplicate()
		fruit["is_picked"] = false
		initial_fruits_temp.append(fruit)
	
	# If for some reason we still don't have 6 fruits (e.g., very limited fruit list),
	# fill with duplicates or placeholders. (Shouldn't be an issue with current `all_fruits`)
	while initial_fruits_temp.size() < 6:
		initial_fruits_temp.append({ "name": "Placeholder", "quality": "bad", "is_picked": false })

	initial_fruits_temp.shuffle() # Shuffle the initial set to randomize positions
	current_grid_fruits = initial_fruits_temp
	update_buttons_display()

func reshuffle_unpicked_fruits():
	# This function is called when a BAD fruit is picked.
	# It preserves already picked good fruits and re-generates the others.

	var new_selectable_fruits_for_slots: Array[Dictionary] = []
	var available_fruits_pool = all_fruits.duplicate()

	# Get names of fruits that are currently picked (and should stay)
	var names_of_currently_picked_good_fruits = []
	for fruit_data in current_grid_fruits:
		if fruit_data.get("is_picked", false):
			names_of_currently_picked_good_fruits.append(fruit_data["name"])
	
	# Filter out these picked fruits from the available pool for new selections
	available_fruits_pool = available_fruits_pool.filter(func(f): 
		return not names_of_currently_picked_good_fruits.has(f["name"])
	)

	var good_available = available_fruits_pool.filter(func(f): return f["quality"] == "good")
	var bad_available = available_fruits_pool.filter(func(f): return f["quality"] == "bad")

	var num_unpicked_slots = 6 - picked_good_fruits_count
	var num_good_needed_for_completion = 3 - picked_good_fruits_count

	# Determine how many good fruits to include in the new selectable set for the unpicked slots.
	# Ensure at least 'num_good_needed_for_completion' good fruits are present,
	# but always at least 2 if we still need more than 0 good fruits to complete the task.
	var num_good_to_add_to_new_set = max(0, num_good_needed_for_completion)
	if picked_good_fruits_count < 3: # If task not complete
		num_good_to_add_to_new_set = max(num_good_to_add_to_new_set, 2) # Ensure at least 2 good options
	
	# Clamp to actual available good fruits
	num_good_to_add_to_new_set = min(num_good_to_add_to_new_set, good_available.size())

	# Add the required number of good fruits to the new selectable set
	good_available.shuffle()
	for i in range(num_good_to_add_to_new_set):
		var fruit = good_available.pop_front().duplicate()
		fruit["is_picked"] = false # Ensure new fruits are not marked as picked
		new_selectable_fruits_for_slots.append(fruit)

	# Fill the remaining slots with a mix of remaining good and bad fruits
	var combined_remaining = good_available + bad_available
	combined_remaining.shuffle()

	while new_selectable_fruits_for_slots.size() < num_unpicked_slots and combined_remaining.size() > 0:
		var fruit = combined_remaining.pop_front().duplicate()
		fruit["is_picked"] = false
		new_selectable_fruits_for_slots.append(fruit)

	# If we still don't have enough fruits to fill the slots (e.g., ran out of unique fruits), fill with bad ones
	while new_selectable_fruits_for_slots.size() < num_unpicked_slots:
		new_selectable_fruits_for_slots.append({ "name": "FillerBad", "quality": "bad", "is_picked": false }) # Fallback

	new_selectable_fruits_for_slots.shuffle() # Shuffle the newly generated selectable fruits

	# Now, update current_grid_fruits by replacing only the unpicked slots
	var new_selectable_index = 0
	for i in range(6):
		if not current_grid_fruits[i].get("is_picked", false):
			# This slot was not picked, so replace it with a new selectable fruit
			if new_selectable_index < new_selectable_fruits_for_slots.size():
				current_grid_fruits[i] = new_selectable_fruits_for_slots[new_selectable_index]
				new_selectable_index += 1
			else:
				# Fallback if somehow we run out of new selectable fruits (shouldn't happen)
				current_grid_fruits[i] = { "name": "N/A", "quality": "bad", "is_picked": false }

	update_buttons_display()


func update_buttons_display():
	# Iterate through all 6 buttons in the grid
	for i in range(grid.get_child_count()):
		var btn := grid.get_child(i) as Button
		
		# Disconnect any existing signals to prevent multiple connections
		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)

		if i < current_grid_fruits.size():
			var fruit = current_grid_fruits[i]
			btn.text = fruit["name"]
			
			if fruit.get("is_picked", false):
				btn.disabled = true # Already picked good fruit
			else:
				btn.disabled = false # Selectable fruit
				# Pass the index to handle_pick so we can update the correct fruit in current_grid_fruits
				btn.pressed.connect(func():
					handle_pick(fruit, btn, i) 
				)
		else:
			btn.text = ""
			btn.disabled = true

func handle_pick(fruit: Dictionary, btn: Button, index_in_grid: int):
	if task_finished:
		return

	btn.disabled = true # Disable the button immediately after it's picked

	if fruit["quality"] == "good":
		# Mark this fruit as picked in our internal grid array
		current_grid_fruits[index_in_grid]["is_picked"] = true
		
		picked_good_fruits_count += 1
		print("✅ Correct fruit picked: %s. Total good fruits: %d" % [fruit["name"], picked_good_fruits_count])
		
		emit_signal("task_completed", 100, true) # Emit points for each correct pick

		if picked_good_fruits_count >= 3:
			task_finished = true
			instruction.text = "Great job! Fruit sorting task complete!"
			await get_tree().create_timer(0.5).timeout
			# Disable all buttons on the grid once the task is complete
			for b in grid.get_children():
				b.disabled = true
			emit_signal("task_completed", 0, true) # Final signal for task completion
		else:
			# If good fruit picked, just update the button state. NO reshuffle of others.
			update_buttons_display() # Re-render to ensure disabled state is applied
	else:
		print("❌ Incorrect fruit picked: %s" % fruit["name"])
		emit_signal("task_completed", 0, false)
		await get_tree().create_timer(0.3).timeout
		# Regenerate the selectable fruits when a bad one is picked
		reshuffle_unpicked_fruits()
