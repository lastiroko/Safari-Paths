# test/minimal_test_runner.gd
extends Node

func _ready():
	print("Starting Safari Paths Tests...")
	
	# Create GUT
	var gut = preload("res://addons/gut/gut.gd").new()
	add_child(gut)
	
	# Add individual test scripts
	var test_scripts = [
		# Unit tests
		"res://test/unit/test_game_manager.gd",
		"res://test/unit/test_addition_task.gd",
		"res://test/unit/test_fruit_sort_task.gd",
		"res://test/unit/test_match_letters_task.gd",
		"res://test/unit/test_subtraction_task.gd",
		# Add more as needed...
	]
	
	# Add each script
	for script in test_scripts:
		if FileAccess.file_exists(script):
			gut.add_script(script)
			print("Added: %s" % script)
		else:
			print("Not found: %s" % script)
	
	# Simple completion handler
	gut.end_run.connect(func():
		print("\n--- Results ---")
		print("Tests: %d" % gut.get_test_count())
		print("Passed: %d" % gut.get_pass_count())
		print("Failed: %d" % gut.get_fail_count())
	)
	
	# Run!
	gut.test_scripts()
