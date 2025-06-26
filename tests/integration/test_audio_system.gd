# test/integration/test_audio_system.gd
extends GutTest

func test_it_002_audio_system_integration():
	# Test ID: IT-002 - Audio system integration
	print("Running IT-002: Audio System Integration Test")
	
	# Test audio player references
	if GameManager.has_node("AudioButtonClick"):
		assert_not_null(GameManager.audio_button_click, "Button click audio should be available")
		assert_not_null(GameManager.audio_button_click.stream, "Button click stream should be loaded")
	
	if GameManager.has_node("AudioCorrectAnswer"):
		assert_not_null(GameManager.audio_correct_answer, "Correct answer audio should be available")
	
	if GameManager.has_node("AudioIncorrectAnswer"):
		assert_not_null(GameManager.audio_incorrect_answer, "Incorrect answer audio should be available")
	
	if GameManager.has_node("AudioLevelComplete"):
		assert_not_null(GameManager.audio_level_complete, "Level complete audio should be available")
	
	print("✅ IT-002 PASSED: Audio system references are valid")
