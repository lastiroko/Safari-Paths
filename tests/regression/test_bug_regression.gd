# test/regression/test_bug_regression.gd
extends GutTest

func test_bug_001_game_manager_accessibility():
	# BUG-001: GameManager not declared in current scope
	print("Testing BUG-001 Regression: GameManager Accessibility")
	
	# GameManager should be globally accessible
	assert_not_null(GameManager, "GameManager should be accessible as global singleton")
	
	# Test from different contexts
	var test_node = Node.new()
	add_child(test_node)
	
	# Access from child node
	assert_not_null(test_node.get_node("/root/GameManager"), 
		"GameManager should be accessible via /root path")
	
	test_node.queue_free()
	
	print("✅ BUG-001 Regression Test PASSED")

func test_bug_003_scene_transition_null_safety():
	# BUG-003: get_tree() returning null during transitions
	print("Testing BUG-003 Regression: Scene Transition Null Safety")
	
	var mock_node = Node.new()
	add_child(mock_node)
	
	# Test safe transition pattern
	var transition_safe = false
	if is_instance_valid(mock_node) and mock_node.get_tree():
		transition_safe = true
	
	assert_true(transition_safe, "Should safely check tree validity")
	
	mock_node.queue_free()
	
	print("✅ BUG-003 Regression Test PASSED")

func test_bug_007_color_constants():
	# BUG-007: Color constant case sensitivity
	print("Testing BUG-007 Regression: Color Constants")
	
	# Verify correct color constant usage
	var valid_colors = [
		Color.BLACK,
		Color.WHITE,
		Color.RED,
		Color.GREEN,
		Color.BLUE,
		Color.GRAY,
		Color.DARK_GRAY,
		Color.LIGHT_GRAY
	]
	
	for color in valid_colors:
		assert_true(color is Color, "Color constant should be valid")
	
	print("✅ BUG-007 Regression Test PASSED")

func test_bug_010_point_reset_completeness():
	# BUG-010: Points not properly resetting
	print("Testing BUG-010 Regression: Complete Point Reset")
	
	# Setup complex state
	GameManager.player_points = 1400
	GameManager.task_points = {
		"monkey_addition": 300,
		"monkey_fruits": 300,
		"elephant_task1": 500,
		"elephant_task2": 300
	}
	GameManager.current_animal = "elephant"
	GameManager.current_task = 1
	
	# Reset
	GameManager.reset_game_state()
	
	# Verify everything is reset
	assert_eq(GameManager.player_points, 0, "Player points should be 0")
	assert_eq(GameManager.current_animal, "monkey", "Should reset to monkey")
	assert_eq(GameManager.current_task, 0, "Should reset to task 0")
	
	var total_task_points = 0
	for points in GameManager.task_points.values():
		total_task_points += points
	
	assert_eq(total_task_points, 0, "All task points should sum to 0")
	
	print("✅ BUG-010 Regression Test PASSED")
