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
var task_finished := false # New flag to indicate when the task is internally complete

func _ready():
	randomize()
	generate_question()

func generate_question():
	# Prevent generating new questions if the task is already finished
	if task_finished:
		return

	var a = randi() % 5 + 1
	var b = randi() % 5 + 1
	correct_answer = a + b
	question_label.text = "What is %d + %d?" % [a, b]

	var answers = [correct_answer]
	# Generate 2 fake answers, ensuring they are not the correct answer and are unique
	while answers.size() < 3:
		var fake = randi() % 9 + 1 # Adjust range as needed for appropriate difficulty
		if fake != correct_answer and not answers.has(fake):
			answers.append(fake)
	answers.shuffle() # Randomize the order of answers

	# Assign answers to buttons and connect signals
	for i in range(3):
		var val = answers[i]
		buttons[i].text = str(val)
		
		# Disconnect any existing signals to prevent multiple connections
		for c in buttons[i].get_signal_connection_list("pressed"):
			buttons[i].disconnect("pressed", c.callable)

		# Connect the pressed signal to the handle_answer function
		buttons[i].pressed.connect(func():
			handle_answer(val)
		)

func handle_answer(selected: int):
	# If the task is finished, ignore further button presses
	if task_finished:
		return

	if selected == correct_answer:
		correct_answers_given += 1
		print("✅ Correct! Total correct answers: %d" % correct_answers_given)
		
		# Always emit 100 points for a correct answer
		emit_signal("task_completed", 100, true)

		# Check if the task's internal completion condition is met (3 correct answers)
		if correct_answers_given >= 3:
			task_finished = true # Mark the task as finished
			# Disable all buttons to prevent further interaction
			for btn in buttons:
				btn.disabled = true
			question_label.text = "Great job! Addition task complete!" # Update instruction
		else:
			# If not yet finished, generate a new question
			generate_question()
	else:
		print("❌ Incorrect. Selected %d, expected %d" % [selected, correct_answer])
		# Emit 0 points for an incorrect answer, as before
		emit_signal("task_completed", 0, false)
		# Generate a new question regardless of correctness
		generate_question()
