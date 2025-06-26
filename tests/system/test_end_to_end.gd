# test/system/test_end_to_end.gd
extends GutTest

func test_st_001_complete_gameplay_flow():
	# Test ID: ST-001 - Complete gameplay session
	print("Running ST-001: End-to-End Gameplay Flow Test")
	
	# Reset game state
	GameManager.reset_game_state()
	assert_eq(GameManager.player_points, 0, "Should start with 0 points")
	
	# Simulate Addition Task completion (300 points)
	for i in range(3):
		GameManager.award_points(100, "monkey_addition")
	assert_eq(GameManager.task_points["monkey_addition"], 300, "Addition task should have 300 points")
	
	# Simulate Fruit Sort Task completion (300 points)
	for i in range(3):
		GameManager.award_points(100, "monkey_fruits")
	assert_eq(GameManager.player_points, 600, "Should have 600 points after MonkeyLevel")
	
	# Simulate Match Letters Task completion (500 points)
	for i in range(5):
		GameManager.award_points(100, "elephant_task1")
	assert_eq(GameManager.task_points["elephant_task1"], 500, "Match letters should have 500 points")
	
	# Simulate Subtraction Task completion (300 points)
	for i in range(3):
		GameManager.award_points(100, "elephant_task2")
	
	# Verify final state
	assert_eq(GameManager.player_points, 1400, "Should have 1400 total points")
	assert_eq(GameManager.task_points["monkey_addition"], 300, "Addition: 300 points")
	assert_eq(GameManager.task_points["monkey_fruits"], 300, "Fruit sort: 300 points")
	assert_eq(GameManager.task_points["elephant_task1"], 500, "Match letters: 500 points")
	assert_eq(GameManager.task_points["elephant_task2"], 300, "Subtraction: 300 points")
	
	# Test restart functionality
	GameManager.reset_game_state()
	assert_eq(GameManager.player_points, 0, "Points should reset to 0")
	for key in GameManager.task_points:
		assert_eq(GameManager.task_points[key], 0, "%s should reset to 0" % key)
	
	print("✅ ST-001 PASSED: Complete gameplay flow works correctly with 1400 points")
