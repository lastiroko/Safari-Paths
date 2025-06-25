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
var picked_good_fruits_count := 0
var task_finished := false

func _ready():
	randomize()
	instruction.text = "🍎 Pick the ripe fruits!"
	initialize_grid_with_fruits()

func initialize_grid_with_fruits():
	if task_finished:
		instruction.text = "Great job! Fruit sorting task complete!"
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
		fruit["is_picked"] = false
		initial_fruits_temp.append(fruit)
		good_fruits_added_to_initial_set += 1

	var remaining_slots = 6 - initial_fruits_temp.size()
	var combined_remaining = bad_candidates + good_candidates.slice(good_fruits_added_to_initial_set)
	combined_remaining.shuffle()

	for i in range(min(remaining_slots, combined_remaining.size())):
		var fruit = combined_remaining[i].duplicate()
		fruit["is_picked"] = false
		initial_fruits_temp.append(fruit)

	while initial_fruits_temp.size() < 6:
		initial_fruits_temp.append({ "name": "Placeholder", "quality": "bad", "is_picked": false })

	initial_fruits_temp.shuffle()
	current_grid_fruits = initial_fruits_temp
	update_buttons_display()

func reshuffle_unpicked_fruits():
	var new_selectable_fruits_for_slots: Array[Dictionary] = []
	var available_fruits_pool = all_fruits.duplicate()

	var names_of_currently_picked_good_fruits = []
	for fruit_data in current_grid_fruits:
		if fruit_data.get("is_picked", false):
			names_of_currently_picked_good_fruits.append(fruit_data["name"])

	available_fruits_pool = available_fruits_pool.filter(func(f):
		return not names_of_currently_picked_good_fruits.has(f["name"])
	)

	var good_available = available_fruits_pool.filter(func(f): return f["quality"] == "good")
	var bad_available = available_fruits_pool.filter(func(f): return f["quality"] == "bad")

	var num_unpicked_slots = 6 - picked_good_fruits_count
	var num_good_needed_for_completion = 3 - picked_good_fruits_count

	var num_good_to_add_to_new_set = max(0, num_good_needed_for_completion)
	if picked_good_fruits_count < 3:
		num_good_to_add_to_new_set = max(num_good_to_add_to_new_set, 2)

	num_good_to_add_to_new_set = min(num_good_to_add_to_new_set, good_available.size())

	good_available.shuffle()
	for i in range(num_good_to_add_to_new_set):
		var fruit = good_available.pop_front().duplicate()
		fruit["is_picked"] = false
		new_selectable_fruits_for_slots.append(fruit)

	var combined_remaining = good_available + bad_available
	combined_remaining.shuffle()

	while new_selectable_fruits_for_slots.size() < num_unpicked_slots and combined_remaining.size() > 0:
		var fruit = combined_remaining.pop_front().duplicate()
		fruit["is_picked"] = false
		new_selectable_fruits_for_slots.append(fruit)

	while new_selectable_fruits_for_slots.size() < num_unpicked_slots:
		new_selectable_fruits_for_slots.append({ "name": "FillerBad", "quality": "bad", "is_picked": false })

	new_selectable_fruits_for_slots.shuffle()

	var new_selectable_index = 0
	for i in range(6):
		if not current_grid_fruits[i].get("is_picked", false):
			if new_selectable_index < new_selectable_fruits_for_slots.size():
				current_grid_fruits[i] = new_selectable_fruits_for_slots[new_selectable_index]
				new_selectable_index += 1
			else:
				current_grid_fruits[i] = { "name": "N/A", "quality": "bad", "is_picked": false }

	update_buttons_display()


func update_buttons_display():
	for i in range(grid.get_child_count()):
		var btn := grid.get_child(i) as TextureButton

		# Set minimum size
		btn.custom_minimum_size = Vector2(128, 128)

		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)

		if i < current_grid_fruits.size():
			var fruit = current_grid_fruits[i]
			btn.tooltip_text = fruit["name"]

			# Load the texture
			var tex_path = "res://assets/fruits/%s.png" % fruit["name"]
			var texture = load(tex_path) if ResourceLoader.exists(tex_path) else null
			btn.texture_normal = texture

			if fruit.get("is_picked", false):
				btn.disabled = true
			else:
				btn.disabled = false
				btn.pressed.connect(func():
					GameManager.play_button_click_sound()
					handle_pick(fruit, btn, i)
				)
		else:
			btn.tooltip_text = ""
			btn.texture_normal = null
			btn.disabled = true

func handle_pick(fruit: Dictionary, btn: TextureButton, index_in_grid: int):
	if task_finished:
		return

	btn.disabled = true

	if fruit["quality"] == "good":
		current_grid_fruits[index_in_grid]["is_picked"] = true
		picked_good_fruits_count += 1
		print("✅ Correct fruit picked: %s. Total good fruits: %d" % [fruit["name"], picked_good_fruits_count])
		GameManager.play_correct_sound()

		emit_signal("task_completed", 100, true)

		if picked_good_fruits_count >= 3:
			task_finished = true
			instruction.text = " "
			for b in grid.get_children():
				b.disabled = true
				if b is TextureButton:
					b.texture_normal = null
			emit_signal("task_completed", 0, true)
		else:
			update_buttons_display()
	else:
		GameManager.play_incorrect_sound()
		emit_signal("task_completed", 0, false)

		if not task_finished:
			if is_instance_valid(self):
				await get_tree().create_timer(0.3).timeout
				reshuffle_unpicked_fruits()
			else:
				print("Node invalid, cannot create timer for reshuffle.")
