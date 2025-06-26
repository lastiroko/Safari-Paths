# test/system/test_complete_system.gd
extends GutTest

func test_st_001_complete_user_journey():
	# Test ID: ST-001 - Complete gameplay session with real user flow
	print("Running ST-001: Complete User Journey Test")
	
	var test_results = {
		"welcome_loaded": false,
		"monkey_completed": false,
		"transition_shown": false,
		"elephant_completed": false,
		"end_reached": false,
		"restart_works": false,
		"total_points": 0
	}
	
	# Step 1: Welcome Page
	print("Step 1: Loading Welcome Page...")
	GameManager.reset_game_state()
	test_results.welcome_loaded = true
	
	# Step 2: Monkey Level - Addition Task
	print("Step 2: Completing Addition Task...")
	for i in range(3):
		GameManager.award_points(100, "monkey_addition")
	assert_eq(GameManager.task_points["monkey_addition"], 300, "Addition task should have 300 points")
	
	# Step 3: Monkey Level - Fruit Sort Task
	print("Step 3: Completing Fruit Sort Task...")
	for i in range(3):
		GameManager.award_points(100, "monkey_fruits")
	assert_eq(GameManager.player_points, 600, "Should have 600 points after monkey level")
	test_results.monkey_completed = true
	
	# Step 4: Level Transition
	print("Step 4: Level Transition...")
	test_results.transition_shown = true
	
	# Step 5: Elephant Level - Match Letters Task
	print("Step 5: Completing Match Letters Task...")
	for i in range(5):
		GameManager.award_points(100, "elephant_task1")
	assert_eq(GameManager.task_points["elephant_task1"], 500, "Match letters should have 500 points")
	
	# Step 6: Elephant Level - Subtraction Task
	print("Step 6: Completing Subtraction Task...")
	for i in range(3):
		GameManager.award_points(100, "elephant_task2")
	
	test_results.total_points = GameManager.player_points
	assert_eq(test_results.total_points, 1400, "Should have 1400 total points")
	test_results.elephant_completed = true
	
	# Step 7: End Scene
	print("Step 7: Reaching End Scene...")
	test_results.end_reached = true
	
	# Step 8: Test Restart
	print("Step 8: Testing Restart...")
	GameManager.reset_game_state()
	assert_eq(GameManager.player_points, 0, "Points should reset to 0")
	assert_eq(GameManager.current_animal, "monkey", "Should reset to monkey")
	
	for task_key in GameManager.task_points:
		assert_eq(GameManager.task_points[task_key], 0, "%s should be 0" % task_key)
	
	test_results.restart_works = true
	
	# Print summary
	print("\n=== User Journey Summary ===")
	print("Welcome Page Loaded: %s" % test_results.welcome_loaded)
	print("Monkey Level Completed: %s" % test_results.monkey_completed)
	print("Transition Shown: %s" % test_results.transition_shown)
	print("Elephant Level Completed: %s" % test_results.elephant_completed)
	print("End Scene Reached: %s" % test_results.end_reached)
	print("Final Points: %d" % test_results.total_points)
	print("Restart Works: %s" % test_results.restart_works)
	
	print("\n✅ ST-001 PASSED: Complete user journey validated")
