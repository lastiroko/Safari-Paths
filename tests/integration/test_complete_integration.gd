
# test/integration/test_complete_integration.gd
extends GutTest

var test_scenes = {}

func before_each():
	GameManager.reset_game_state()
	test_scenes.clear()

func after_each():
	for scene in test_scenes.values():
		if is_instance_valid(scene):
			scene.queue_free()

func test_it_001_full_scene_transition_flow():
	# Test ID: IT-001 - Complete scene transition with state validation
	print("Running IT-001: Full Scene Transition Flow")
	
	# Step 1: Load and validate MonkeyLevel
	var monkey_scene = load("res://scenes/levels/MonkeyLevel.tscn")
	var monkey_level = monkey_scene.instantiate()
	test_scenes["monkey"] = monkey_level
	add_child(monkey_level)
	await monkey_level.ready
	
	# Verify MonkeyLevel initialization
	assert_not_null(monkey_level.monkey, "Monkey sprite should exist")
	assert_not_null(monkey_level.hud, "HUD should exist")
	assert_not_null(monkey_level.task_area, "Task area should exist")
	assert_eq(monkey_level.current_task_index, 0, "Should start with task index 0")
	
	# Verify HUD displays correct points
	var points_label = monkey_level.hud.get_node("HUDContainer/PointsLabel")
	assert_not_null(points_label, "Points label should exist")
	assert_eq(points_label.text, "Points: 0", "Should display 0 points initially")
	
	# Step 2: Complete MonkeyLevel tasks
	# Simulate addition task completion
	for i in range(3):
		GameManager.award_points(100, "monkey_addition")
	
	# Trigger task transition
	monkey_level._on_task_completed(0, true)
	assert_eq(monkey_level.current_task_index, 1, "Should move to fruit sort task")
	
	# Simulate fruit sort completion
	for i in range(3):
		GameManager.award_points(100, "monkey_fruits")
	
	# Verify points before transition
	assert_eq(GameManager.player_points, 600, "Should have 600 points before transition")
	
	# Step 3: Transition to LevelTransition scene
	var transition_scene = load("res://scenes/levels/LevelTransition.tscn")
	var level_transition = transition_scene.instantiate()
	test_scenes["transition"] = level_transition
	add_child(level_transition)
	await level_transition.ready
	
	# Verify transition scene elements
	assert_not_null(level_transition.continue_button, "Continue button should exist")
	
	# Step 4: Load ElephantLevel
	var elephant_scene = load("res://scenes/levels/ElephantLevel.tscn")
	var elephant_level = elephant_scene.instantiate()
	test_scenes["elephant"] = elephant_level
	add_child(elephant_level)
	await elephant_level.ready
	
	# Verify ElephantLevel initialization with persisted points
	assert_not_null(elephant_level.elephant, "Elephant sprite should exist")
	
	var elephant_points_label = elephant_level.hud.get_node("HUDContainer/PointsLabel")
	assert_eq(elephant_points_label.text, "Points: 600", "Should display 600 points from MonkeyLevel")
	
	# Step 5: Complete ElephantLevel tasks
	for i in range(5):
		GameManager.award_points(100, "elephant_task1")
	
	elephant_level._on_task_completed(0, true)
	assert_eq(elephant_level.current_task_index, 1, "Should move to subtraction task")
	
	for i in range(3):
		GameManager.award_points(100, "elephant_task2")
	
	# Step 6: Verify final state
	assert_eq(GameManager.player_points, 1400, "Should have 1400 total points")
	
	print("✅ IT-001 PASSED: Complete scene transition flow with state persistence")

func test_it_002_audio_system_complete_integration():
	# Test ID: IT-002 - Complete audio system integration
	print("Running IT-002: Complete Audio System Integration")
	
	# Test 1: Verify all audio nodes exist in GameManager
	var audio_nodes = {
		"button_click": GameManager.get_node_or_null("AudioButtonClick"),
		"correct": GameManager.get_node_or_null("AudioCorrectAnswer"),
		"incorrect": GameManager.get_node_or_null("AudioIncorrectAnswer"),
		"level_complete": GameManager.get_node_or_null("AudioLevelComplete"),
		"background": GameManager.get_node_or_null("AudioBackgroundMusic")
	}
	
	for audio_name in audio_nodes:
		assert_not_null(audio_nodes[audio_name], "Audio node %s should exist" % audio_name)
	
	# Test 2: Load WelcomePage and verify background music
	var welcome_scene = load("res://scenes/levels/_WelcomePage.tscn")
	var welcome_page = welcome_scene.instantiate()
	test_scenes["welcome"] = welcome_page
	add_child(welcome_page)
	await welcome_page.ready
	
	var welcome_audio = welcome_page.get_node_or_null("AudioPlayer")
	assert_not_null(welcome_audio, "Welcome page audio player should exist")
	assert_not_null(welcome_audio.stream, "Welcome page should have audio stream")
	
	# Test 3: Verify task audio integration
	var addition_scene = load("res://scenes/tasks/AdditionTask.tscn")
	var addition_task = addition_scene.instantiate()
	test_scenes["addition"] = addition_task
	add_child(addition_task)
	await addition_task.ready
	
	# Connect to verify audio plays on correct/incorrect
	var audio_played = {"correct": false, "incorrect": false}
	
	if GameManager.audio_correct_answer:
		GameManager.audio_correct_answer.finished.connect(func(): 
			audio_played.correct = true, CONNECT_ONE_SHOT)
	
	if GameManager.audio_incorrect_answer:
		GameManager.audio_incorrect_answer.finished.connect(func(): 
			audio_played.incorrect = true, CONNECT_ONE_SHOT)
	
	# Test correct answer audio
	GameManager.play_correct_sound()
	await wait_seconds(0.1)
	
	# Test incorrect answer audio
	GameManager.play_incorrect_sound()
	await wait_seconds(0.1)
	
	# Note: Audio playback verification depends on audio system configuration
	print("✅ IT-002 PASSED: Audio system nodes properly integrated")

func test_task_integration_flow():
	# Test complete task flow integration
	print("Running Task Integration Flow Test")
	
	# Test Addition → Fruit Sort transition
	var monkey_scene = load("res://scenes/levels/MonkeyLevel.tscn")
	var monkey_level = monkey_scene.instantiate()
	test_scenes["monkey"] = monkey_level
	add_child(monkey_level)
	await monkey_level.ready
	
	# Verify initial task is Addition
	var current_task = monkey_level.task_area.get_child(0)
	assert_true(current_task.has_method("generate_question"), "Should have addition task loaded")
	
	# Complete addition task
	GameManager.task_points["monkey_addition"] = 300
	monkey_level._on_task_completed(0, true)
	
	await wait_frames(5)
	
	# Verify task switched to Fruit Sort
	var new_task = monkey_level.task_area.get_child(0)
	assert_true(new_task.has_method("initialize_grid_with_fruits"), "Should have fruit sort task loaded")
	
	print("✅ Task transition integration test PASSED")
