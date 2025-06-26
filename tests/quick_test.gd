# test/quick_test.gd
extends "res://addons/gut/test.gd"

func test_gut_is_working():
	assert_true(true, "GUT is working!")
	assert_eq(1 + 1, 2, "Basic math works")
	print("✅ GUT framework is properly installed!")

func test_game_manager_exists():
	assert_not_null(GameManager, "GameManager should be accessible")
	print("✅ GameManager is accessible!")
