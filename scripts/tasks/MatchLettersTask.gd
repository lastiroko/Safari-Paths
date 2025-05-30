extends Control
signal task_completed(points_awarded: int, was_correct: bool)

# Corrected paths assuming InstructionLabel, GridLetters, and GridPictures
# are all children of a VBoxContainer, which is a child of the root MatchLetters node.
@onready var instruction_label = $InstructionLabel
@onready var letters_grid = $VBoxContainer/GridLetters
@onready var pictures_grid = $VBoxContainer/GridPictures
 # Add an AudioStreamPlayer node named 'AudioIncorrectMatch' in your scene

var pairs = [
	{ "letter": "B", "color": "Blue" },
	{ "letter": "O", "color": "Orange" },
	{ "letter": "P", "color": "Purple" },
	{ "letter": "Y", "color": "Yellow" },
	{ "letter": "G", "color": "Green" }
]

var selected_picture_button: Button = null # Stores the currently selected picture button
var selected_letter_button: Button = null  # Stores the currently selected letter button
var task_finished = false
var matches_made = 0

func _ready():
	randomize()
	instruction_label.text = "🧩 Match the letter to the color!"
	generate_ui()

func generate_ui():
	# Setup Pictures Grid
	var shuffled_pictures = pairs.duplicate()
	shuffled_pictures.shuffle()

	for i in range(5):
		var btn = pictures_grid.get_child(i) as Button
		btn.text = shuffled_pictures[i]["color"]
		btn.disabled = false # Initially enabled
		btn.modulate = Color(1, 1, 1) # Reset color
		btn.set_meta("letter", shuffled_pictures[i]["letter"]) # Store the associated letter
		btn.set_meta("matched", false) # Track if this button has been part of a correct match
		
		# Disconnect any old signals to prevent multiple connections
		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)
		btn.pressed.connect(func():
			handle_picture_selected(btn)
		)

	# Setup Letters Grid
	var shuffled_letters = pairs.duplicate() # Shuffle letters too for initial random order
	shuffled_letters.shuffle()

	for i in range(5):
		var btn = letters_grid.get_child(i) as Button
		btn.text = shuffled_letters[i]["letter"] # Use shuffled letters for display
		btn.disabled = false # Initially enabled
		btn.set_meta("letter", shuffled_letters[i]["letter"]) # Store the letter itself
		btn.set_meta("matched", false) # Track if this button has been part of a correct match
		
		# Disconnect any old signals to prevent multiple connections
		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)
		btn.pressed.connect(func():
			handle_letter_selected(btn)
		)

func handle_picture_selected(btn: Button):
	if btn.get_meta("matched") or task_finished:
		return # Ignore if already matched or task is finished

	selected_picture_button = btn
	
	# Disable all other picture buttons to enforce single selection
	for b in pictures_grid.get_children():
		if b != selected_picture_button and not b.get_meta("matched"):
			b.disabled = true
	
	# Enable all unmatched letter buttons so the user can pick a letter
	for b in letters_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false
	
	# If a letter was already selected, check for a match immediately
	if selected_letter_button != null:
		check_match()

func handle_letter_selected(btn: Button):
	if btn.get_meta("matched") or task_finished:
		return # Ignore if already matched or task is finished

	selected_letter_button = btn
	
	# Disable all other letter buttons to enforce single selection
	for b in letters_grid.get_children():
		if b != selected_letter_button and not b.get_meta("matched"):
			b.disabled = true
	
	# Enable all unmatched picture buttons so the user can pick a picture
	for b in pictures_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false
	
	# If a picture was already selected, check for a match immediately
	if selected_picture_button != null:
		check_match()

func check_match():
	# Only proceed if both a letter and a picture are selected
	if selected_letter_button == null or selected_picture_button == null:
		return

	var letter_meta = selected_letter_button.get_meta("letter")
	var picture_meta_letter = selected_picture_button.get_meta("letter")

	if letter_meta == picture_meta_letter:
		# Correct match
		print("✅ Correct Match: %s (Letter) -> %s (Color)" % [selected_letter_button.text, selected_picture_button.text])
		
		# Permanently disable and mark as matched
		selected_letter_button.disabled = true
		selected_letter_button.set_meta("matched", true)
		selected_picture_button.disabled = true
		selected_picture_button.set_meta("matched", true)
		
		matches_made += 1
		emit_signal("task_completed", 100, true) # Award points for correct match

		# Reset selection for the next match
		reset_selection()

		if matches_made >= 5: # Assuming 5 matches complete the task
			task_finished = true
			instruction_label.text = "🎉 Great job! You matched all!"
			# Emit 0 points as the task is fully completed and no more points are to be awarded for this task.
			emit_signal("task_completed", 0, true) 
	else:
		# Incorrect match
		print("❌ Incorrect Match: %s (Letter) vs %s (Color)" % [selected_letter_button.text, selected_picture_button.text])
		#_on_incorrect_match_sound() # Play incorrect sound
		emit_signal("task_completed", 0, false) # Emit 0 points for incorrect match

		# Reset selection for the next attempt, re-enabling unmatched buttons
		reset_selection()

func reset_selection():
	selected_letter_button = null
	selected_picture_button = null

	# Re-enable all unmatched letter buttons
	for b in letters_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false
	
	# Re-enable all unmatched picture buttons
	for b in pictures_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false

#func _on_incorrect_match_sound():
	#if audio_incorrect_match:
		#audio_incorrect_match.play()
