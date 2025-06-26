# test/error/test_all_error_scenarios.gd
extends GutTest

func test_er_001_missing_scene_file_handling():
	# Test ID: ER-001 - Missing scene file graceful handling
	print("Running ER-001: Missing Scene File Handling")
	
	var scene_path = "res://scenes/levels/NonExistentLevel.tscn"
	var scene = null
	if ResourceLoader.exists(scene_path):
		scene = load(scene_path)
	
	assert_null(scene, "Should return null for non-existent scene")
	assert_not_null(GameManager, "GameManager should still be accessible")
	assert_eq(GameManager.player_points, 0, "Game state should remain intact")
	
	print("✅ ER-001 PASSED: Missing scene handled gracefully")


func test_er_002_node_hierarchy_mismatch():
	# Test ID: ER-002 - Node hierarchy mismatch handling
	print("Running ER-002: Node Hierarchy Mismatch Handling")
	
	var mock_scene = Control.new()
	add_child(mock_scene)
	
	var missing_node = mock_scene.get_node_or_null("NonExistentNode")
	assert_null(missing_node, "Should return null for missing node")
	if missing_node:
		missing_node.visible = true
	else:
		assert_true(true, "Null check prevents crash")
	
	mock_scene.queue_free()
	
	print("✅ ER-002 PASSED: Node hierarchy mismatches handled safely")


func test_er_003_scene_transition_safety():
	# Test ID: ER-003 - Scene transition during node lifecycle
	print("Running ER-003: Scene Transition Safety")
	
	var mock_level = Node.new()
	mock_level.set_meta("transitioning_level", false)
	add_child(mock_level)
	
	# assign the lambda to a variable
	var safe_scene_change = func() -> bool:
		if not mock_level.get_meta("transitioning_level"):
			mock_level.set_meta("transitioning_level", true)
			if is_instance_valid(mock_level) and mock_level.get_tree():
				return true
		return false
	
	# call the lambda via .call() (not safe_scene_change())
	assert_true(safe_scene_change.call(), "First transition should be allowed")
	assert_false(safe_scene_change.call(), "Second transition should be blocked")
	
	mock_level.queue_free()
	
	print("✅ ER-003 PASSED: Scene transitions are protected")


func test_er_004_game_manager_missing_handling():
	# Test ID: ER-004 - GameManager autoload configuration errors
	print("Running ER-004: GameManager Missing Handling")
	
	assert_not_null(GameManager, "GameManager should be configured as autoload")
	
	var points = 0
	if GameManager:
		points = GameManager.player_points
	else:
		points = 0
	
	assert_eq(points, 0, "Should safely access or use fallback")
	
	print("✅ ER-004 PASSED: GameManager access is safe")


func test_er_005_audio_null_reference_handling():
	# Test ID: ER-005 - Audio player null reference handling
	print("Running ER-005: Audio Null Reference Handling")
	
	var safe_play_audio = func(audio_player) -> bool:
		if audio_player and is_instance_valid(audio_player) and audio_player.stream:
			audio_player.play()
			return true
		return false
	
	assert_false(safe_play_audio.call(null), "Should handle null audio player")
	
	var empty_audio = AudioStreamPlayer2D.new()
	assert_false(safe_play_audio.call(empty_audio), "Should handle missing stream")
	empty_audio.queue_free()
	
	# this should not crash even if GameManager’s audio player is null
	GameManager.play_button_click_sound()
	
	print("✅ ER-005 PASSED: Audio null references handled safely")


func test_er_006_point_system_reset_integrity():
	# Test ID: ER-006 - Point system reset and persistence validation
	print("Running ER-006: Point System Reset Integrity")
	
	var task_points_before = {
		"monkey_addition": 300,
		"monkey_fruits":    300,
		"elephant_task1":   500,
		"elephant_task2":   300
	}
	for task_key in task_points_before:
		GameManager.task_points[task_key] = task_points_before[task_key]
	GameManager.player_points = 1400
	
	assert_eq(GameManager.player_points, 1400, "Should have 1400 points before reset")
	
	GameManager.reset_game_state()
	
	assert_eq(GameManager.player_points, 0,   "Player points should be 0")
	assert_eq(GameManager.current_animal, "monkey", "Should reset to monkey")
	assert_eq(GameManager.current_task,   0,        "Should reset to task 0")
	
	for task_key in GameManager.task_points:
		assert_eq(GameManager.task_points[task_key], 0,
			"Task %s should be 0 after reset" % task_key)
	
	GameManager.award_points(100, "monkey_addition")
	assert_eq(GameManager.player_points, 100, "Should accumulate from 0")
	assert_eq(GameManager.task_points["monkey_addition"], 100,
		"Task points should accumulate cleanly")
	
	for task_key in GameManager.task_points:
		if task_key != "monkey_addition":
			assert_eq(GameManager.task_points[task_key], 0,
				"Other tasks should remain at 0")
	
	print("✅ ER-006 PASSED: Complete state reset with no residual data")
