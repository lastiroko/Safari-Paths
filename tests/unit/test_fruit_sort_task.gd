# test/unit/test_fruit_sort_task.gd
extends GutTest

var fruit_sort_scene = preload("res://scenes/tasks/FruitSortTask.tscn")
var fruit_sort_task

func before_each():
	fruit_sort_task = fruit_sort_scene.instantiate()
	add_child(fruit_sort_task)
	await fruit_sort_task.ready

func after_each():
	fruit_sort_task.queue_free()

func test_ut_002_fruit_sort_logic_and_reshuffle():
	# Test ID: UT-002 - Test fruit sort logic and reshuffle mechanism
	print("Running UT-002: Fruit Sort Logic and Reshuffle Test")
	
	var total_points = 0
	var good_fruits_picked = []
	var signals_received = []
	
	# Connect to task_completed signal
	fruit_sort_task.connect("task_completed", func(points, was_correct):
		signals_received.append({"points": points, "was_correct": was_correct})
		total_points += points
	)
	
	# Test 1: Pick a good fruit
	var good_fruit_index = -1
	var good_fruit_button = null
	for i in range(6):
		if i < fruit_sort_task.current_grid_fruits.size():
			var fruit = fruit_sort_task.current_grid_fruits[i]
			if fruit["quality"] == "good" and not fruit.get("is_picked", false):
				good_fruit_index = i
				good_fruit_button = fruit_sort_task.grid.get_child(i)
				break
	
	assert_ne(good_fruit_index, -1, "Should find at least one good fruit")
	
	# Pick the good fruit
	var good_fruit_name = fruit_sort_task.current_grid_fruits[good_fruit_index]["name"]
	fruit_sort_task.handle_pick(
		fruit_sort_task.current_grid_fruits[good_fruit_index],
		good_fruit_button,
		good_fruit_index
	)
	
	# Verify good fruit behavior
	assert_eq(fruit_sort_task.current_grid_fruits[good_fruit_index]["is_picked"], true, "Good fruit should be marked as picked")
	assert_eq(good_fruit_button.disabled, true, "Good fruit button should be disabled")
	assert_eq(fruit_sort_task.picked_good_fruits_count, 1, "Good fruits count should be 1")
	assert_eq(signals_received.last().points, 100, "Should award 100 points for good fruit")
	assert_eq(signals_received.last().was_correct, true, "Should indicate correct pick")
	
	good_fruits_picked.append(good_fruit_name)
	
	# Test 2: Pick a bad fruit to trigger reshuffle
	var bad_fruit_index = -1
	var bad_fruit_button = null
	for i in range(6):
		if i < fruit_sort_task.current_grid_fruits.size():
			var fruit = fruit_sort_task.current_grid_fruits[i]
			if fruit["quality"] == "bad" and not fruit.get("is_picked", false):
				bad_fruit_index = i
				bad_fruit_button = fruit_sort_task.grid.get_child(i)
				break
	
	assert_ne(bad_fruit_index, -1, "Should find at least one bad fruit")
	
	# Pick the bad fruit
	fruit_sort_task.handle_pick(
		fruit_sort_task.current_grid_fruits[bad_fruit_index],
		bad_fruit_button,
		bad_fruit_index
	)
	
	# Wait for reshuffle
	await wait_seconds(0.5)
	
	# Verify bad fruit behavior
	assert_eq(signals_received.last().points, 0, "Should award 0 points for bad fruit")
	assert_eq(signals_received.last().was_correct, false, "Should indicate incorrect pick")
	
	# Test 3: Verify good fruits persist through reshuffle
	var still_picked = false
	for i in range(6):
		if i < fruit_sort_task.current_grid_fruits.size():
			var fruit = fruit_sort_task.current_grid_fruits[i]
			if fruit.get("is_picked", false) and fruit["name"] == good_fruit_name:
				still_picked = true
				break
	
	assert_eq(still_picked, true, "Previously picked good fruit should persist through reshuffle")
	
	# Test 4: Verify at least 2 good fruits available after reshuffle
	var available_good_fruits = 0
	for i in range(6):
		if i < fruit_sort_task.current_grid_fruits.size():
			var fruit = fruit_sort_task.current_grid_fruits[i]
			if fruit["quality"] == "good" and not fruit.get("is_picked", false):
				available_good_fruits += 1
	
	assert_gte(available_good_fruits, 2, "Should have at least 2 good fruits available after reshuffle")
	
	# Test 5: Complete task with 3 good fruits
	while fruit_sort_task.picked_good_fruits_count < 3:
		for i in range(6):
			if i < fruit_sort_task.current_grid_fruits.size():
				var fruit = fruit_sort_task.current_grid_fruits[i]
				var button = fruit_sort_task.grid.get_child(i)
				if fruit["quality"] == "good" and not fruit.get("is_picked", false):
					fruit_sort_task.handle_pick(fruit, button, i)
					break
	
	# Verify task completion
	assert_eq(fruit_sort_task.task_finished, true, "Task should be finished after 3 good fruits")
	assert_eq(fruit_sort_task.picked_good_fruits_count, 3, "Should have picked 3 good fruits")
	assert_eq(total_points, 300, "Total points should be 300")
	
	# Verify all buttons disabled
	for button in fruit_sort_task.grid.get_children():
		assert_eq(button.disabled, true, "All buttons should be disabled after completion")
	
	print("✅ UT-002 PASSED: Fruit sort with reshuffle works correctly, 300 points awarded")
