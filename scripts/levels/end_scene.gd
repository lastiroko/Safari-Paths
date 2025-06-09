extends Control
func _on_Restart_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/AWelcomePage.tscn")

func _on_Quit_pressed():
	get_tree().quit()
