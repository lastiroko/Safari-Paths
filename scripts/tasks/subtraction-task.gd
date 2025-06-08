extends Control
signal task_completed(points_awarded: int, was_correct: bool)

@onready var question_label = $QuestionLabel
@onready var buttons := [
	$HBoxContainer/Button1,
	$HBoxContainer/Button2,
	$HBoxContainer/Button3
]

var correct_answer: int
var correct_answers_given := 0
var task_finished := false

func _ready():
	randomize()
	generate_question()

func generate_question():
	if task_finished:
		return
	
	var a: int
	var b: int
	
	# Loop until a suitable 'a' and 'b' are found
	# 'a' and 'b' will now be between 1 and 5
	while true:
		a = randi() % 5 + 1  # Numbers from 1 to 5
		b = randi() % 5 + 1  # Numbers from 1 to 5
		
		# Ensure 'a' is always greater than or equal to 'b' for positive or zero results
		if a < b: # If b is larger, swap them
			var temp = a
			a = b
			b = temp
		
		correct_answer = a - b
		
		# Ensure the correct answer is non-negative (0 or greater).
		# If you want strictly positive answers (e.g., 1 or greater), change to `correct_answer > 0`.
		if correct_answer >= 0: 
			break # Found suitable numbers
	
	question_label.text = "What is %d - %d?" % [a, b]

	var answers = [correct_answer]
	
	# Generate 2 fake answers that are close to the correct answer but not identical
	while answers.size() < 3:
		var fake_answer: int
		var offset = randi() % 2 + 1 # Offset by 1 or 2 from correct answer for smaller range
		
		# Randomly make the offset positive or negative
		if randf() < 0.5:
			fake_answer = correct_answer + offset
		else:
			fake_answer = correct_answer - offset
		
		# Ensure fake answers are within a reasonable range (e.g., 0 to 5 for subtraction 1-5)
		# and are unique and not the correct answer
		if fake_answer >= 0 and fake_answer <= 5 and not answers.has(fake_answer):
			answers.append(fake_answer)
	
	# Fallback: If for some reason we still don't have 3 unique answers (very rare with above logic),
	# fill with completely random numbers in the expected answer range.
	while answers.size() < 3:
		var fallback_fake = randi() % 6 # 0 to 5
		if not answers.has(fallback_fake):
			answers.append(fallback_fake)
			
	answers.shuffle()

	# Assign answers to buttons
	for i in range(3):
		var val = answers[i]
		buttons[i].text = str(val)
		
		# Disconnect old signals to prevent multiple connections
		for c in buttons[i].get_signal_connection_list("pressed"):
			buttons[i].disconnect("pressed", c.callable)

		buttons[i].pressed.connect(func():
			handle_answer(val)
		)

func handle_answer(selected: int):
	if task_finished:
		return

	if selected == correct_answer:
		correct_answers_given += 1
		print("✅ Correct! Total correct answers: %d" % correct_answers_given)
		emit_signal("task_completed", 100, true)

		if correct_answers_given >= 3: # Task complete after 3 correct answers
			task_finished = true
			for btn in buttons:
				btn.disabled = true # Disable all buttons
			question_label.text = "🎉 Great job! Subtraction task complete!"
			# Emit 0 points as the task is fully completed
			emit_signal("task_completed", 0, true)
			get_tree().change_scene_to_file("res://scenes/levels/end_scene.tscn")
 
		else:
			generate_question() # Generate a new question if task not finished
	else:
		print("❌ Incorrect. Selected %d, expected %d" % [selected, correct_answer])
		emit_signal("task_completed", 0, false) # Emit 0 points for incorrect answer
		
		generate_question() # Always generate a new question after an incorrect attempt
