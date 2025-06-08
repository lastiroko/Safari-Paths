extends Control

@onready var audio_player = $AudioPlayer

func _ready():
	# Load and play Ghana to Mississippi background music
	audio_player.stream = preload("res://assets/audio/Ghana to Mississippi.mp3")
	audio_player.play()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/MonkeyLevel.tscn")
