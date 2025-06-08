extends Control
signal task_completed(points_awarded: int, was_correct: bool)

# Corrected paths assuming InstructionLabel is a direct child,
# and GridLetters/GridPictures are children of a VBoxContainer.
@onready var instruction_label = $InstructionLabel
@onready var letters_grid = $VBoxContainer/GridLetters
@onready var pictures_grid = $VBoxContainer/GridPictures
# Removed @onready var for AudioIncorrectMatch as user removed sound references

# Define a dictionary to map color names to Godot Color objects
const COLORS_MAP = {
	"Blue": Color("0000ff"),    # Pure Blue
	"Orange": Color("ff7f00"),  # Orange
	"Purple": Color("800080"),  # Purple
	"Yellow": Color("ffff00"),  # Pure Yellow
	"Green": Color("008000")    # Green (darker for contrast with letters)
}

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

# Helper function to create a StyleBoxFlat for a given color
func _create_color_stylebox(color: Color, border_width: int = 2, border_color: Color = Color.BLACK) -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.set_bg_color(color)
	stylebox.set_border_width_all(0)
	stylebox.set_border_color(border_color)
	stylebox.set_corner_radius_all(8) # Add rounded corners
	return stylebox

# Helper function to apply a style to a button's normal state
func _apply_normal_style(button: Button, color_name: String):
	if COLORS_MAP.has(color_name):
		var normal_color = COLORS_MAP[color_name]
		button.add_theme_stylebox_override("normal", _create_color_stylebox(normal_color))
		# For pressed/hover/disabled states, you might want to define separate styles
		# or derive them from the normal style. For now, Godot's default darkens/lightens.
		button.add_theme_stylebox_override("pressed", _create_color_stylebox(normal_color.darkened(0.2)))
		button.add_theme_stylebox_override("hover", _create_color_stylebox(normal_color.lightened(0.2)))
		# Disabled buttons will just use their default disabled look, which usually desaturates.
		# If you want a specific disabled color:
		button.add_theme_stylebox_override("disabled", _create_color_stylebox(normal_color.darkened(0.5)))
	else:
		# Fallback for unknown colors
		button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.GRAY))


func generate_ui():
	# Setup Pictures Grid (Color Buttons)
	var shuffled_pictures = pairs.duplicate()
	shuffled_pictures.shuffle()

	for i in range(5):
		var btn = pictures_grid.get_child(i) as Button
		btn.text = "" # No text, button will show color
		btn.disabled = false
		btn.set_meta("letter", shuffled_pictures[i]["letter"]) # Still store associated letter
		btn.set_meta("matched", false)
		btn.set_meta("color_name", shuffled_pictures[i]["color"]) # Store color name for easier lookup
		
		_apply_normal_style(btn, shuffled_pictures[i]["color"]) # Apply initial color style

		# Disconnect any old signals to prevent multiple connections
		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)
		btn.pressed.connect(func():
			# GameManager.play_button_click_sound() # User removed sound, keep it commented out.
			handle_picture_selected(btn)
		)

	# Setup Letters Grid (Letter Buttons)
	var shuffled_letters = pairs.duplicate()
	shuffled_letters.shuffle()

	for i in range(5):
		var btn = letters_grid.get_child(i) as Button
		btn.text = shuffled_letters[i]["letter"] # Display letter
		btn.disabled = false
		btn.set_meta("letter", shuffled_letters[i]["letter"])
		btn.set_meta("matched", false)
		
		# Set font color to black for better contrast if background is light
		btn.add_theme_color_override("font_color", Color.BLACK) 
		# You might also want a default StyleBoxFlat for letter buttons
		btn.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 2, Color.DARK_GRAY))
		btn.add_theme_stylebox_override("pressed", _create_color_stylebox(Color.GRAY, 2, Color.DARK_GRAY))
		btn.add_theme_stylebox_override("hover", _create_color_stylebox(Color.WHITE, 2, Color.DARK_GRAY))


		# Disconnect any old signals to prevent multiple connections
		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)
		btn.pressed.connect(func():
			# GameManager.play_button_click_sound() # User removed sound, keep it commented out.
			handle_letter_selected(btn)
		)

func handle_picture_selected(btn: Button):
	if btn.get_meta("matched") or task_finished:
		return

	# Reset previous selection highlight if any
	if selected_picture_button != null:
		_apply_normal_style(selected_picture_button, selected_picture_button.get_meta("color_name"))
	
	selected_picture_button = btn
	# Apply selected style
	selected_picture_button.add_theme_stylebox_override("normal", _create_color_stylebox(selected_picture_button.get_meta("color_name"), 4, Color.GREEN)) # Green border for selected

	# Disable all other picture buttons to enforce single selection
	for b in pictures_grid.get_children():
		if b != selected_picture_button and not b.get_meta("matched"):
			b.disabled = true
	
	# Enable all unmatched letter buttons
	for b in letters_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false
	
	if selected_letter_button != null:
		check_match()

func handle_letter_selected(btn: Button):
	if btn.get_meta("matched") or task_finished:
		return

	# Reset previous selection highlight if any
	if selected_letter_button != null:
		# Re-apply its normal style, assuming letters have a consistent base style
		selected_letter_button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 2, Color.DARK_GRAY))
	
	selected_letter_button = btn
	# Apply selected style (e.g., thicker green border for selected letter)
	selected_letter_button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 4, Color.GREEN))


	# Disable all other letter buttons
	for b in letters_grid.get_children():
		if b != selected_letter_button and not b.get_meta("matched"):
			b.disabled = true
	
	# Enable all unmatched picture buttons
	for b in pictures_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false
	
	if selected_picture_button != null:
		check_match()

func check_match():
	if selected_letter_button == null or selected_picture_button == null:
		return

	var letter_meta = selected_letter_button.get_meta("letter")
	var picture_meta_letter = selected_picture_button.get_meta("letter")

	if letter_meta == picture_meta_letter:
		print("✅ Correct Match: %s (Letter) -> %s (Color)" % [selected_letter_button.text, selected_picture_button.get_meta("color_name")])
		# GameManager.play_correct_sound() # User removed sound, keep it commented out.
		
		# Permanently disable and mark as matched
		selected_letter_button.disabled = true
		selected_letter_button.set_meta("matched", true)
		selected_picture_button.disabled = true
		selected_picture_button.set_meta("matched", true)
		
		# Apply a "matched" visual style (e.g., a checkmark, or different background color, or just disabled)
		# For example, to make matched buttons look slightly different but disabled:
		selected_letter_button.add_theme_stylebox_override("disabled", _create_color_stylebox(Color.GRAY.lightened(0.2), 2, Color.BLUE))
		selected_picture_button.add_theme_stylebox_override("disabled", _create_color_stylebox(COLORS_MAP[selected_picture_button.get_meta("color_name")].lightened(0.2), 2, Color.BLUE))


		matches_made += 1
		emit_signal("task_completed", 100, true)

		reset_selection()

		if matches_made >= 5:
			task_finished = true
			instruction_label.text = "🎉 Great job! You matched all!"
			emit_signal("task_completed", 0, true) 
	else:
		print("❌ Incorrect Match: %s (Letter) vs %s (Color)" % [selected_letter_button.text, selected_picture_button.get_meta("color_name")])
		# GameManager.play_incorrect_sound() # User removed sound, keep it commented out.
		emit_signal("task_completed", 0, false)

		# Reset styles of the two selected buttons to their normal (unselected) appearance before re-enabling
		_apply_normal_style(selected_picture_button, selected_picture_button.get_meta("color_name"))
		selected_letter_button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 2, Color.DARK_GRAY))

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
