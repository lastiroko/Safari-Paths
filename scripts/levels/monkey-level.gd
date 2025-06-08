extends Node

@onready var monkey = $Monkey
@onready var hud = $HUD
@onready var task_area = $Taskarea
@onready var audio_player = $AudioPlayer

var current_task_index = 0

# List of task scenes for the Monkey level
var task_paths = [
	"res://scenes/tasks/AdditionTask.tscn",
	"res://scenes/tasks/FruitSortTask.tscn"
	
]

func _ready():
	load_task(current_task_index)
	monkey.texture = load("res://assets/characters/monkey/monkey_neutral.png")
	print("Loading task") # This print statement indicates the start of the MonkeyLevel

func load_task(index: int):
	# Clear the previous task if any exists in the task_area
	for child in task_area.get_children():
		child.queue_free() # Free up the old task scene

	# Load and instance the new task scene based on the current_task_index
	var task_scene = load(task_paths[index]).instantiate()
	# Connect the "task_completed" signal from the new task scene to this script's handler
	task_scene.connect("task_completed", Callable(self, "_on_task_completed"))
	task_area.add_child(task_scene) # Add the new task scene to the scene tree

func _on_task_completed(points_awarded: int, was_correct: bool):
	var task_key: String
	# Determine the task key based on the current task index
	if current_task_index == 0:
		task_key = "monkey_addition"
	else:
		task_key = "monkey_fruits"

	# Award points if the task signal indicates points should be awarded (i.e., it was a correct action)
	if points_awarded > 0:
		GameManager.award_points(points_awarded, task_key)
	
	# Update the HUD to reflect the current total player points
	hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points

	# Update the monkey's texture based on whether the last action was correct or incorrect
	if was_correct:
		monkey.texture = load("res://assets/characters/monkey/monkey_neutral.png")
	else:
		monkey.texture = load("res://assets/characters/monkey/monkey_sad.png")

	# --- Task Completion Checks ---
	# This logic now runs AFTER points have been potentially awarded,
	# ensuring GameManager.task_points is up-to-date.

	if task_key == "monkey_addition":
		# Check if the total points for the addition task have reached 300
		if GameManager.task_points[task_key] >= 300:
			print("✅ Finished Addition Task (Points: %d). Moving to Fruit Sort." % GameManager.task_points[task_key])
			current_task_index += 1 # Increment to the next task
			load_task(current_task_index) # Load the next task (Fruit Sort)
	elif task_key == "monkey_fruits":
		# Check if the total points for the fruit sort task have reached 300
		if GameManager.task_points[task_key] >= 300:
			print("✅ Finished Fruit Sort Task (Points: %d). Moving to Elephant Level." % GameManager.task_points[task_key])
			# Change to the next level scene (Elephant Level)
			get_tree().change_scene_to_file("res://scenes/levels/Level_transition.tscn")

	
	# The individual task scenes (AdditionTask, FruitSortTask) are responsible for
	# regenerating questions/fruits if the task is not yet complete and an action occurs.
	# No explicit regeneration logic is needed here in MonkeyLevel.
