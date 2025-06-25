extends Control

@onready var continue_button = $ContinueButton

func _ready():
	GameManager.play_level_complete_sound()

	if continue_button:
		continue_button.pressed.connect(Callable(self, "_on_continue_button_pressed"))
	else:
		print("Error: ContinueButton node not found as a direct child of LevelTransition root.")

func _on_continue_button_pressed():
	GameManager.play_button_click_sound()
	get_tree().change_scene_to_file("res://scenes/levels/ElephantLevel.tscn")
