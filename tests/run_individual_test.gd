# test/run_individual_test.gd
extends Node

@export var test_file: String = "res://test/unit/test_game_manager.gd"

func _ready():
	print("Running individual test: %s" % test_file)
	
	var GutTest = load("res://addons/gut/test.gd")
	var gut = GutTest.new()
	add_child(gut)
	
	if ResourceLoader.exists(test_file):
		gut.add_script(test_file)
		gut.end_run.connect(_on_test_complete)
		gut.test_scripts()
	else:
		print("ERROR: Test file not found: %s" % test_file)
		await get_tree().create_timer(2.0).timeout
		get_tree().quit()

func _on_test_complete():
	var gut = get_child(0)
	print("\nTest Results:")
	print("Tests Run: %d" % gut.get_test_count())
	print("Passed: %d" % gut.get_pass_count())
	print("Failed: %d" % gut.get_fail_count())
	
	if gut.get_fail_count() > 0:
		print("\n❌ Test failed!")
	else:
		print("\n✅ Test passed!")
	
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
