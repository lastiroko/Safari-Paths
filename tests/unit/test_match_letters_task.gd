# test/unit/test_match_letters_task.gd
extends GutTest

var match_letters_scene = preload("res://scenes/tasks/MatchLettersTask.tscn")
var match_letters_task

func before_each():
	match_letters_task = match_letters_scene.instantiate()
	add_child(match_letters_task)
	await match_letters_task.ready

func after_each():
	match_letters_task.queue_free()

func test_ut_003_letter_color_matching():
	# Test ID: UT-003 - Test letter-color matching with StyleBoxFlat colors
	print("Running UT-003: Letter-Color Matching Test")
	
	var total_points = 0
	var matches_completed = 0
	var signals_received = []
	
	# Connect to task_completed signal
	match_letters_task.connect("task_completed", func(points, was_correct):
		signals_received.append({"points": points, "was_correct": was_correct})
		if was_correct and points > 0:
			total_points += points
			matches_completed += 1
	)
	
	# Test 1: Verify color buttons display actual colors (not text)
	for i in range(5):
		var color_button = match_letters_task.pictures_grid.get_child(i)
		assert_eq(color_button.text, "", "Color button should not display text")
		
		var style = color_button.get_theme_stylebox("normal")
		assert_not_null(style, "Color button should have a StyleBoxFlat")
		
		if style is StyleBoxFlat:
			var color_name = color_button.get_meta("color_name")
			assert_true(match_letters_task.COLORS_MAP.has(color_name), "Color should be in COLORS_MAP")
	
	# Test 2: Two-step selection (letter then color)
	var letter_button = match_letters_task.letters_grid.get_child(0)
	var letter_value = letter_button.get_meta("letter")
	
	# Select letter first
	match_letters_task.handle_letter_selected(letter_button)
	assert_eq(match_letters_task.selected_letter_button, letter_button, "Letter should be selected")
	
	# Verify other letters are disabled
	for i in range(5):
		var btn = match_letters_task.letters_grid.get_child(i)
		if btn != letter_button and not btn.get_meta("matched"):
			assert_eq(btn.disabled, true, "Non-selected letters should be disabled")
	
	# Find matching color button
	var matching_color_button = null
	for i in range(5):
		var color_button = match_letters_task.pictures_grid.get_child(i)
		if color_button.get_meta("letter") == letter_value:
			matching_color_button = color_button
			break
	
	assert_not_null(matching_color_button, "Should find matching color button")
	
	# Select matching color
	match_letters_task.handle_picture_selected(matching_color_button)
	
	# Verify match
	assert_eq(letter_button.get_meta("matched"), true, "Letter should be marked as matched")
	assert_eq(matching_color_button.get_meta("matched"), true, "Color should be marked as matched")
	assert_eq(signals_received.last().points, 100, "Should award 100 points for match")
	assert_eq(signals_received.last().was_correct, true, "Should indicate correct match")
	
	# Test 3: Complete all 5 matches
	while match_letters_task.matches_made < 5:
		# Find an unmatched letter
		var unmatched_letter = null
		var unmatched_letter_value = ""
		
		for i in range(5):
			var btn = match_letters_task.letters_grid.get_child(i)
			if not btn.get_meta("matched"):
				unmatched_letter = btn
				unmatched_letter_value = btn.get_meta("letter")
				break
		
		if unmatched_letter == null:
			break
		
		# Select the letter
		match_letters_task.handle_letter_selected(unmatched_letter)
		
		# Find and select matching color
		for i in range(5):
			var color_btn = match_letters_task.pictures_grid.get_child(i)
			if color_btn.get_meta("letter") == unmatched_letter_value and not color_btn.get_meta("matched"):
				match_letters_task.handle_picture_selected(color_btn)
				break
		
		await wait_frames(1)
	
	# Verify completion
	assert_eq(match_letters_task.task_finished, true, "Task should be finished")
	assert_eq(match_letters_task.matches_made, 5, "Should have 5 matches")
	assert_eq(total_points, 500, "Total points should be 500")
	
	print("✅ UT-003 PASSED: Letter-color matching works correctly, 500 points awarded")
