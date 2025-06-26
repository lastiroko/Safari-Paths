# test/unit/test_game_manager.gd
extends GutTest

func before_each():
	# Reset GameManager state before each test
	if GameManager:
		GameManager.reset_game_state()

func test_ut_101_game_manager_autoload_accessibility():
	# Test ID: UT-101 - GameManager autoload accessibility
	print("Running UT-101: GameManager Autoload Accessibility Test")
	
	# Test 1: Verify GameManager is accessible
	assert_not_null(GameManager, "GameManager should be accessible as global singleton")
	
	# Test 2: Test player_points initialization
	assert_eq(GameManager.player_points, 0, "player_points should initialize to 0")
	
	# Test 3: Test task_points dictionary structure
	assert_has(GameManager.task_points, "monkey_addition", "Should have monkey_addition key")
	assert_has(GameManager.task_points, "monkey_fruits", "Should have monkey_fruits key")
	assert_has(GameManager.task_points, "elephant_task1", "Should have elephant_task1 key")
	assert_has(GameManager.task_points, "elephant_task2", "Should have elephant_task2 key")
	
	# Verify all task points are 0
	for key in GameManager.task_points:
		assert_eq(GameManager.task_points[key], 0, "Task %s should start at 0 points" % key)
	
	# Test 4: Verify award_points() function
	GameManager.award_points(100, "monkey_addition")
	assert_eq(GameManager.player_points, 100, "player_points should be 100")
	assert_eq(GameManager.task_points["monkey_addition"], 100, "monkey_addition should have 100 points")
	
	# Test with no task key
	GameManager.award_points(50)
	assert_eq(GameManager.player_points, 150, "player_points should be 150")
	
	# Test 5: Test reset_game_state() functionality
	GameManager.reset_game_state()
	assert_eq(GameManager.player_points, 0, "player_points should reset to 0")
	assert_eq(GameManager.current_animal, "monkey", "Should reset to monkey")
	assert_eq(GameManager.current_task, 0, "Should reset to task 0")
	
	for key in GameManager.task_points:
		assert_eq(GameManager.task_points[key], 0, "Task %s should reset to 0" % key)
	
	print("✅ UT-101 PASSED: GameManager global access and functions work correctly")

func test_ut_102_point_system_integrity():
	# Test ID: UT-102 - Point system integrity across scenes
	print("Running UT-102: Point System Integrity Test")
	
	# Simulate completing monkey_addition task
	for i in range(3):
		GameManager.award_points(100, "monkey_addition")
	
	assert_eq(GameManager.player_points, 300, "Should have 300 total points")
	assert_eq(GameManager.task_points["monkey_addition"], 300, "monkey_addition should have 300 points")
	
	# Simulate transition (points should persist)
	var points_before_transition = GameManager.player_points
	
	# Simulate completing monkey_fruits task
	for i in range(3):
		GameManager.award_points(100, "monkey_fruits")
	
	assert_eq(GameManager.player_points, 600, "Should have 600 total points")
	assert_eq(GameManager.task_points["monkey_fruits"], 300, "monkey_fruits should have 300 points")
	assert_eq(GameManager.task_points["monkey_addition"], 300, "monkey_addition should still have 300 points")
	
	# Test point accumulation across all tasks
	GameManager.award_points(500, "elephant_task1")
	assert_eq(GameManager.player_points, 1100, "Should have 1100 total points")
	
	GameManager.award_points(300, "elephant_task2")
	assert_eq(GameManager.player_points, 1400, "Should have 1400 total points")
	
	print("✅ UT-102 PASSED: Point persistence and accumulation work correctly")
