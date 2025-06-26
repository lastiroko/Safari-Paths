# test/unit/test_subtraction_task.gd
extends GutTest

var subtraction_scene = preload("res://scenes/tasks/SubtractionTask.tscn")
var subtraction_task

func before_each():
	subtraction_task = subtraction_scene.instantiate()
	add_child(subtraction_task)
	await subtraction_task.ready

func after_each():
	subtraction_task.queue_free()

func test_subtraction_task_completion():
	# Test subtraction task completion (similar to addition)
	print("Running Subtraction Task Completion Test")
	
	var total_points = 0
	var signals_received = []
	
	subtraction_task.connect("task_completed", func(points, was_correct):
		signals_received.append({"points": points, "was_correct": was_correct})
		if was_correct:
			total_points += points
	)
	
	# Complete 3 correct answers
	for i in range(3):
		var correct_answer = subtraction_task.correct_answer
		subtraction_task.handle_answer(correct_answer)
		
		assert_eq(signals_received[i].points, 100, "Should award 100 points per correct answer")
		assert_eq(signals_received[i].was_correct, true, "Should indicate correct answer")
	
	# Verify completion
	assert_eq(subtraction_task.task_finished, true, "Task should be finished")
	assert_eq(subtraction_task.correct_answers_given, 3, "Should have 3 correct answers")
	assert_eq(total_points, 300, "Total points should be 300")
	
	print("✅ Subtraction task completion test PASSED")
