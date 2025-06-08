extends Node

@onready var elephant = $Elephant
@onready var hud = $HUD
@onready var task_area = $Taskarea
@onready var audio_player = $AudioStreamPlayer2D
@onready var correct_audio_player = $CorrectAudioPlayer
@onready var incorrect_audio_player = $IncorrectAudioPlayer

var current_task_index = 0

# List of task scenes for the Elephant level
var task_paths = [
	"res://scenes/tasks/MatchLettersTask.tscn",
	"res://scenes/tasks/SubtractionTask.tscn"
]

func _ready():
	# Load and play Ghana to Mississippi background music
	audio_player.stream = preload("res://assets/audio/Ghana to Mississippi.mp3")
	audio_player.play()
	
	load_task(current_task_index)
	elephant.texture = load("res://assets/characters/elephant/elephant_neutral.png")
	print("Loading Elephant Task")
	
	# --- FIX: Initialize HUD points when ElephantLevel loads ---
	# Ensure the HUD's PointsLabel reflects the current total points from GameManager
	if hud and hud.has_node("HUDContainer/PointsLabel"):
		hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points
	else:
		print("Warning: HUD or PointsLabel not found in ElephantLevel's _ready().")

func load_task(index: int):
	# Clear previous task
	for child in task_area.get_children():
		child.queue_free()

	# Load and instance new task
	var task_scene = load(task_paths[index]).instantiate()
	task_scene.connect("task_completed", Callable(self, "_on_task_completed"))
	task_area.add_child(task_scene)

func _on_task_completed(points_awarded: int, was_correct: bool):
	var task_key: String
	if current_task_index == 0:
		task_key = "elephant_task1"
	else:
		task_key = "elephant_task2"

	# Award points if correct
	if points_awarded > 0:
		GameManager.award_points(points_awarded, task_key)

	# Update HUD
	hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points

	# Update elephant expression and play correct/incorrect audio
	if was_correct:
		elephant.texture = load("res://assets/characters/elephant/elephant_neutral.png")
		$CorrectAudioPlayer.play()
	else:
		elephant.texture = load("res://assets/characters/elephant/elephant_sad.png")
		$IncorrectAudioPlayer.play()

	# Task Completion Logic
	if task_key == "elephant_task1":
		if GameManager.task_points[task_key] >= 500:
			print("✅ Finished Match Letters Task. Moving to Subtraction Task.")
			current_task_index += 1
			load_task(current_task_index)
	elif task_key == "elephant_task2":
		if GameManager.task_points[task_key] >= 300:
			print("✅ Finished Elephant Level. Moving to Lion Level!")
			get_tree().change_scene_to_file("res://scenes/levels/LionLevel.tscn")
