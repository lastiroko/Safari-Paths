extends Control
signal task_completed(points_awarded: int, was_correct: bool)

# Corrected paths assuming InstructionLabel is a direct child,
# and GridLetters/GridPictures are children of a VBoxContainer.
@onready var instruction_label = $InstructionLabel
@onready var letters_grid = $VBoxContainer/GridLetters
@onready var pictures_grid = $VBoxContainer/GridPictures

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

var selected_picture_button: Button = null
var selected_letter_button: Button = null
var task_finished = false
var matches_made = 0

func _ready():
	randomize()
	instruction_label.text = "🧩 Match the letter to the color!"
	generate_ui()

func _create_color_stylebox(color: Color, border_width: int = 0, border_color: Color = Color.BLACK) -> StyleBoxFlat:
	var stylebox = StyleBoxFlat.new()
	stylebox.set_bg_color(color)
	stylebox.set_border_width_all(border_width)
	stylebox.set_border_color(border_color)
	stylebox.set_corner_radius_all(8)
	return stylebox

func _apply_normal_style(button: Button, color_name: String):
	if COLORS_MAP.has(color_name):
		var normal_color = COLORS_MAP[color_name]
		button.add_theme_stylebox_override("normal", _create_color_stylebox(normal_color))
		button.add_theme_stylebox_override("pressed", _create_color_stylebox(normal_color.darkened(0.2)))
		button.add_theme_stylebox_override("hover", _create_color_stylebox(normal_color.lightened(0.2)))
		button.add_theme_stylebox_override("disabled", _create_color_stylebox(normal_color.darkened(0.5), 0, Color.TRANSPARENT)) # Disabled also no border
	else:
		button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.GRAY))


func generate_ui():
	var shuffled_pictures = pairs.duplicate()
	shuffled_pictures.shuffle()

	for i in range(5):
		var btn = pictures_grid.get_child(i) as Button
		btn.text = "" # no text, button will show color
		btn.disabled = false
		btn.set_meta("letter", shuffled_pictures[i]["letter"])
		btn.set_meta("matched", false)
		btn.set_meta("color_name", shuffled_pictures[i]["color"])

		_apply_normal_style(btn, shuffled_pictures[i]["color"])

		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)
		btn.pressed.connect(func():
			GameManager.play_button_click_sound()
			handle_picture_selected(btn)
		)

	var shuffled_letters = pairs.duplicate()
	shuffled_letters.shuffle()

	for i in range(5):
		var btn = letters_grid.get_child(i) as Button
		btn.text = shuffled_letters[i]["letter"]
		btn.disabled = false
		btn.set_meta("letter", shuffled_letters[i]["letter"])
		btn.set_meta("matched", false)

		btn.add_theme_color_override("font_color", Color.BLACK)
		btn.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 0, Color.TRANSPARENT))
		btn.add_theme_stylebox_override("pressed", _create_color_stylebox(Color.GRAY, 0, Color.TRANSPARENT))
		btn.add_theme_stylebox_override("hover", _create_color_stylebox(Color.WHITE, 0, Color.TRANSPARENT))
		btn.add_theme_stylebox_override("disabled", _create_color_stylebox(Color.DARK_GRAY.lightened(0.2), 0, Color.TRANSPARENT))


		for c in btn.get_signal_connection_list("pressed"):
			btn.disconnect("pressed", c.callable)
		btn.pressed.connect(func():
			GameManager.play_button_click_sound()
			handle_letter_selected(btn)
		)

func handle_picture_selected(btn: Button):
	if btn.get_meta("matched") or task_finished:
		return

	if selected_picture_button != null:
		_apply_normal_style(selected_picture_button, selected_picture_button.get_meta("color_name"))

	selected_picture_button = btn
	selected_picture_button.add_theme_stylebox_override("normal", _create_color_stylebox(selected_picture_button.get_meta("color_name"), 4, Color.GREEN))

	for b in pictures_grid.get_children():
		if b != selected_picture_button and not b.get_meta("matched"):
			b.disabled = true

	for b in letters_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false

	if selected_letter_button != null:
		check_match()

func handle_letter_selected(btn: Button):
	if btn.get_meta("matched") or task_finished:
		return

	if selected_letter_button != null:
		selected_letter_button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 0, Color.TRANSPARENT))

	selected_letter_button = btn
	selected_letter_button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 4, Color.GREEN))


	for b in letters_grid.get_children():
		if b != selected_letter_button and not b.get_meta("matched"):
			b.disabled = true

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

		GameManager.play_correct_sound()

		selected_letter_button.disabled = true
		selected_letter_button.set_meta("matched", true)
		selected_picture_button.disabled = true
		selected_picture_button.set_meta("matched", true)


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

		GameManager.play_incorrect_sound() # Re-enabled sound call
		emit_signal("task_completed", 0, false)

		# Reset styles of the two selected buttons to their normal (unselected) appearance before re-enabling
		_apply_normal_style(selected_picture_button, selected_picture_button.get_meta("color_name"))
		selected_letter_button.add_theme_stylebox_override("normal", _create_color_stylebox(Color.LIGHT_GRAY, 0, Color.TRANSPARENT))

		reset_selection()

func reset_selection():
	selected_letter_button = null
	selected_picture_button = null

	for b in letters_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false

	for b in pictures_grid.get_children():
		if not b.get_meta("matched"):
			b.disabled = false
