
# test/unit/test_addition_task.gd
extends GutTest

var addition_task_scene = preload("res://scenes/tasks/AdditionTask.tscn")
var addition_task

func before_each():
	addition_task = addition_task_scene.instantiate()
	add_child(addition_task)
	await addition_task.ready

func after_each():
	addition_task.queue_free()

func test_ut_001_addition_task_completion():
	# Test ID: UT-001 - Validate addition task completion and point emission
	print("Running UT-001: Addition Task Completion Test")
	
	var correct_answers_count = 0
	var total_points = 0
	var task_completed_signals = []
	
	# Connect to task_completed signal
	addition_task.connect("task_completed", func(points, was_correct):
		task_completed_signals.append({"points": points, "was_correct": was_correct})
		if was_correct:
			total_points += points
	)
	
	# Simulate 3 correct answers
	for i in range(3):
		var correct_answer = addition_task.correct_answer
		addition_task.handle_answer(correct_answer)
		correct_answers_count += 1
		
		# Verify correct signal emission
		assert_eq(task_completed_signals.size(), i + 1, "Signal should be emitted for answer %d" % (i + 1))
		assert_eq(task_completed_signals[i].points, 100, "Should emit 100 points per correct answer")
		assert_eq(task_completed_signals[i].was_correct, true, "Should indicate correct answer")
	
	# Verify task completion
	assert_eq(addition_task.task_finished, true, "Task should be finished after 3 correct answers")
	assert_eq(total_points, 300, "Total points should be 300")
	assert_eq(addition_task.correct_answers_given, 3, "Should have 3 correct answers")
	
	# Verify buttons are disabled
	for button in addition_task.buttons:
		assert_eq(button.disabled, true, "All buttons should be disabled after completion")
	
	print("✅ UT-001 PASSED: Addition task completes correctly with 300 points")

func test_addition_incorrect_answer_handling():
	# Additional test for incorrect answer handling
	print("Running Addition Task Incorrect Answer Test")
	
	var signals_received = []
	addition_task.connect("task_completed", func(points, was_correct):
		signals_received.append({"points": points, "was_correct": was_correct})
	)
	
	# Get an incorrect answer
	var correct_answer = addition_task.correct_answer
	var incorrect_answer = correct_answer + 1 if correct_answer < 10 else correct_answer - 1
	
	# Submit incorrect answer
	addition_task.handle_answer(incorrect_answer)
	
	# Verify signal emission
	assert_eq(signals_received.size(), 1, "Should emit signal for incorrect answer")
	assert_eq(signals_received[0].points, 0, "Should emit 0 points for incorrect answer")
	assert_eq(signals_received[0].was_correct, false, "Should indicate incorrect answer")
	
	# Verify task continues
	assert_eq(addition_task.task_finished, false, "Task should not be finished")
	assert_eq(addition_task.correct_answers_given, 0, "Correct answers should remain 0")
	
	print("✅ Incorrect answer handling test PASSED")
