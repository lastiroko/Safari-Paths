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
	var settings := LabelSettings.new()
	settings.font_size = 60
	question_label.label_settings = settings

	randomize()
	generate_question()
	randomize()
	generate_question()

func generate_question():
	if task_finished:
		return

	var a = randi() % 5 + 1
	var b = randi() % 5 + 1
	correct_answer = a + b

	question_label.text = "What is %d + %d?" % [a, b]

	# Generate answer choices
	var answers = [correct_answer]
	var max_attempts = 20
	var attempts = 0

	while answers.size() < 3 and attempts < max_attempts:
		var fake_answer: int
		var offset = randi() % 3 + 1

		if randf() < 0.5:
			fake_answer = correct_answer + offset
		else:
			fake_answer = correct_answer - offset

		if fake_answer >= 0 and fake_answer <= 15 and not answers.has(fake_answer):
			answers.append(fake_answer)

		attempts += 1

	while answers.size() < 3:
		var fallback_fake = randi() % 16
		if not answers.has(fallback_fake):
			answers.append(fallback_fake)

	answers.shuffle()


	for i in range(3):
		var val = answers[i]
		buttons[i].text = str(val)

		for c in buttons[i].get_signal_connection_list("pressed"):
			buttons[i].disconnect("pressed", c.callable)

		buttons[i].pressed.connect(func():
			GameManager.play_button_click_sound()
			handle_answer(val)
		)

func handle_answer(selected: int):
	if task_finished:
		return

	if selected == correct_answer:
		correct_answers_given += 1
		GameManager.play_correct_sound()
		emit_signal("task_completed", 100, true)

		if correct_answers_given >= 3:
			task_finished = true
			for btn in buttons:
				btn.disabled = true
			question_label.text = "You are really good at Math!"
		else:
			generate_question()
	else:
		GameManager.play_incorrect_sound()
		emit_signal("task_completed", 0, false)
		generate_question()
