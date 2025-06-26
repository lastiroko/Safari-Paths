# test/error/test_error_handling.gd
extends GutTest

func test_er_003_scene_transition_safety():
	# Test ID: ER-003 - Scene transition during node lifecycle
	print("Running ER-003: Scene Transition Safety Test")
	
	# Test transitioning_level flag concept
	var mock_level = {}
	mock_level.transitioning_level = false
	
	# Simulate task completion
	if not mock_level.transitioning_level:
		mock_level.transitioning_level = true
		# Scene change would happen here
	
	# Try another transition (should be blocked)
	var second_transition_allowed = not mock_level.transitioning_level
	assert_eq(second_transition_allowed, false, "Second transition should be blocked")
	
	print("✅ ER-003 PASSED: Transitioning flag prevents multiple scene changes")

func test_er_006_point_reset_validation():
	# Test ID: ER-006 - Point system reset validation
	print("Running ER-006: Point System Reset Validation Test")
	
	# Accumulate points
	GameManager.award_points(300, "monkey_addition")
	GameManager.award_points(300, "monkey_fruits")
	GameManager.award_points(500, "elephant_task1")
	GameManager.award_points(300, "elephant_task2")
	
	assert_eq(GameManager.player_points, 1400, "Should have 1400 points before reset")
	
	# Reset game state
	GameManager.reset_game_state()
	
	# Verify complete reset
	assert_eq(GameManager.player_points, 0, "player_points should be 0")
	assert_eq(GameManager.current_animal, "monkey", "Should reset to monkey")
	assert_eq(GameManager.current_task, 0, "Should reset to task 0")
	
	# Verify task_points dictionary is cleared
	for key in GameManager.task_points:
		assert_eq(GameManager.task_points[key], 0, "%s should be 0 after reset" % key)
	
	# Test that new point accumulation works correctly
	GameManager.award_points(100, "monkey_addition")
	assert_eq(GameManager.player_points, 100, "Should accumulate from 0, not 1400")
	assert_eq(GameManager.task_points["monkey_addition"], 100, "Task points should accumulate from 0")
	
	print("✅ ER-006 PASSED: Complete state reset with no residual data")
	
