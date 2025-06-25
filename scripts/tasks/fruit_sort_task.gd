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

var current_grid_fruits: Array[Dictionary] = []
var picked_good_fruits: Array[String] = []  # Store names of picked good fruits
var task_finished := false

func _ready():
	randomize()
	instruction.text = " Pick the ripe fruits!"
	var settings := LabelSettings.new()
	settings.font_size = 40
	instruction.label_settings = settings
	initialize_grid_with_fruits()

func initialize_grid_with_fruits():
	if task_finished:
		#instruction.text = "Great job! Fruit sorting task complete!"
		for btn in grid.get_children():
			btn.disabled = true
			if btn is TextureButton:
				btn.texture_normal = null
			btn.text = ""
		return

	current_grid_fruits.clear()
	var temp_all_fruits = all_fruits.duplicate()
	temp_all_fruits.shuffle()

	var good_fruits_added_to_initial_set = 0
	var initial_fruits_temp: Array[Dictionary] = []

	var good_candidates = temp_all_fruits.filter(func(f): return f["quality"] == "good")
	var bad_candidates = temp_all_fruits.filter(func(f): return f["quality"] == "bad")

	for i in range(min(3, good_candidates.size())):
		var fruit = good_candidates[i].duplicate()
		initial_fruits_temp.append(fruit)
		good_fruits_added_to_initial_set += 1

	var remaining_slots = 6 - initial_fruits_temp.size()
	var combined_remaining = bad_candidates + good_candidates.slice(good_fruits_added_to_initial_set)
	combined_remaining.shuffle()

	for i in range(min(remaining_slots, combined_remaining.size())):
		var fruit = combined_remaining[i].duplicate()
		initial_fruits_temp.append(fruit)

	while initial_fruits_temp.size() < 6:
		initial_fruits_temp.append({ "name": "Placeholder", "quality": "bad" })

	initial_fruits_temp.shuffle()
	current_grid_fruits = initial_fruits_temp
	update_buttons_display()

func reshuffle_unpicked_fruits():
	var new_selectable_fruits_for_slots: Array[Dictionary] = []
	var available_fruits_pool = all_fruits.duplicate()

	# Filter out already picked good fruits
	available_fruits_pool = available_fruits_pool.filter(func(f):
		return not picked_good_fruits.has(f["name"])
	)

	var good_available = available_fruits_pool.filter(func(f): return f["quality"] == "good")
	var bad_available = available_fruits_pool.filter(func(f): return f["quality"] == "bad")

	var num_unpicked_slots = 6 - picked_good_fruits.size()
	var num_good_needed_for_completion = 3 - picked_good_fruits.size()

	var num_good_to_add_to_new_set = max(0, num_good_needed_for_completion)
	if picked_good_fruits.size() < 3:
		num_good_to_add_to_new_set = max(num_good_to_add_to_new_set, 2)

	num_good_to_add_to_new_set = min(num_good_to_add_to_new_set, good_available.size())

	good_available.shuffle()
	for i in range(num_good_to_add_to_new_set):
		var fruit = good_available.pop_front().duplicate()
		new_selectable_fruits_for_slots.append(fruit)

	var combined_remaining = good_available + bad_available
	combined_remaining.shuffle()

	while new_selectable_fruits_for_slots.size() < num_unpicked_slots and combined_remaining.size() > 0:
		var fruit = combined_remaining.pop_front().duplicate()
		new_selectable_fruits_for_slots.append(fruit)

	while new_selectable_fruits_for_slots.size() < num_unpicked_slots:
		new_selectable_fruits_for_slots.append({ "name": "FillerBad", "quality": "bad" })

	new_selectable_fruits_for_slots.shuffle()

	# Create new grid combining picked good fruits and new selectable fruits
	var new_grid: Array[Dictionary] = []

	# First, add all picked good fruits back to their positions
	for picked_name in picked_good_fruits:
		var picked_fruit = all_fruits.filter(func(f): return f["name"] == picked_name)[0].duplicate()
		new_grid.append(picked_fruit)

	# Then add the new selectable fruits
	for fruit in new_selectable_fruits_for_slots:
		new_grid.append(fruit)

	# Shuffle only if we have less than 6 items, then pad to 6
	while new_grid.size() < 6:
		new_grid.append({ "name": "N/A", "quality": "bad" })

	new_grid.shuffle()
	current_grid_fruits = new_grid
	update_buttons_display()

func update_buttons_display():
	for i in range(grid.get_child_count()):
		var btn := grid.get_child(i) as TextureButton

		btn.custom_minimum_size = Vector2(128, 128)

		# Clear previous connections
		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)

		if i < current_grid_fruits.size():
			var fruit = current_grid_fruits[i]
			btn.tooltip_text = fruit["name"]

			var tex_path = "res://assets/fruits/%s.png" % fruit["name"]
			var texture = load(tex_path) if ResourceLoader.exists(tex_path) else null
			btn.texture_normal = texture

			# Check if this fruit has been picked (is in our picked_good_fruits array)
			var is_picked = picked_good_fruits.has(fruit["name"])

			if is_picked:
				# Previously picked good fruit - show as disabled with grey tint
				btn.disabled = true
				btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			else:
				# Unpicked fruit - show as normal and clickable
				btn.disabled = false
				btn.modulate = Color.WHITE  # Reset to normal color
				btn.mouse_filter = Control.MOUSE_FILTER_PASS

				btn.pressed.connect(func():
					GameManager.play_button_click_sound()
					handle_pick(fruit, btn, i)
				)
		else:
			btn.tooltip_text = ""
			btn.texture_normal = null
			btn.disabled = true
			btn.modulate = Color.WHITE

func handle_pick(fruit: Dictionary, btn: TextureButton, index_in_grid: int):
	if task_finished:
		return

	if fruit["quality"] == "good":
		# Add to picked fruits list
		picked_good_fruits.append(fruit["name"])

		# Update button appearance immediately
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE

		GameManager.play_correct_sound()
		emit_signal("task_completed", 100, true)

		if picked_good_fruits.size() >= 3:
			task_finished = true
			#instruction.text = "Great job! Fruit sorting task complete!"
			for b in grid.get_children():
				b.disabled = true
				if b is TextureButton:
					b.texture_normal = null
			emit_signal("task_completed", 0, true)
		else:
			# Don't reshuffle immediately for good fruits
			pass
	else:
		# Bad fruit clicked
		GameManager.play_incorrect_sound()
		emit_signal("task_completed", 0, false)

		if not task_finished:
			if is_instance_valid(self):
				await get_tree().create_timer(0.3).timeout
				reshuffle_unpicked_fruits()
			else:
				print("Node invalid, cannot create timer for reshuffle.")
