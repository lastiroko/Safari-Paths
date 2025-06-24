extends Control

@onready var audio_player = $AudioPlayer

func _ready():
	audio_player.stream = preload("res://assets/audio/Ghana_to_Mississippi.mp3")
	audio_player.play()

func _on_play_button_pressed() -> void:
	GameManager.play_button_click_sound()
	GameManager.stop_background_music()
	get_tree().change_scene_to_file("res://scenes/levels/MonkeyLevel.tscn")
