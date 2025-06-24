extends Control

@onready var restart_button = $RestartButton
@onready var quit_button = $QuitButton
@onready var congratulation_label = $CongratulationsLabel

func _ready():
	print("Welcome to the End Scene!")
	GameManager.play_level_complete_sound()
	GameManager.stop_background_music()

	congratulation_label.text = "CONGRATULATIONS!\nYOU COMPLETED THE GAME!"

	if not restart_button.is_connected("pressed", Callable(self, "_on_Restart_pressed")):
		restart_button.pressed.connect(_on_Restart_pressed)

	if not quit_button.is_connected("pressed", Callable(self, "_on_Quit_pressed")):
		quit_button.pressed.connect(_on_Quit_pressed)

func _on_Restart_pressed():
	GameManager.play_button_click_sound()
	GameManager.reset_game_state()
	get_tree().change_scene_to_file("res://scenes/levels/_WelcomePage.tscn")

func _on_Quit_pressed():
	GameManager.play_button_click_sound()
	get_tree().quit()
