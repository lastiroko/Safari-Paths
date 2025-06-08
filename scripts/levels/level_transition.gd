extends Control
@onready var anim_player = $AnimationPlayer

func _ready():
	print("Welcome to the Level Transition Scene!")

	var continue_button = $ContinueButton
	if continue_button:
		continue_button.connect("pressed", Callable(self, "_on_continue_button_pressed"))
	else:
		print("❌ Error: ContinueButton node not found.")

func _on_continue_button_pressed():
	print("Continue button pressed. Loading Elephant Level...")
	get_tree().change_scene_to_file("res://scenes/levels/ElephantLevel.tscn")
