extends Node

@onready var monkey = $Monkey
@onready var hud = $HUD
@onready var task_area = $Taskarea
@onready var audio_player = $AudioPlayer # For level-specific background music

var current_task_index = 0
var transitioning_level = false # Flag to prevent multiple scene change attempts

# List of task scenes for the Monkey level
var task_paths = [
	"res://scenes/tasks/AdditionTask.tscn",
	"res://scenes/tasks/FruitSortTask.tscn"
]

func _ready():
	# Start level background music
	if audio_player and audio_player.stream == null:
		audio_player.stream = preload("res://assets/audio/Kalahari_Dreaming.mp3") # Ensure this path is correct
	audio_player.play()

	load_task(current_task_index)
	if monkey:
		monkey.texture = load("res://assets/characters/monkey/monkey_neutral.png")
	else:
		print("Warning: Monkey node not found in MonkeyLevel scene.")

	print("Loading Monkey Level Task")

	# Initialize HUD points when MonkeyLevel loads
	if hud and hud.has_node("HUDContainer/PointsLabel"):
		hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points
	else:
		print("Warning: HUD or PointsLabel not found in MonkeyLevel's _ready().")


func load_task(index: int):
	# Clear the previous task if any exists in the task_area
	for child in task_area.get_children():
		child.queue_free()

	# Load and instance the new task scene based on the current_task_index
	var task_scene = load(task_paths[index]).instantiate()
	task_scene.connect("task_completed", Callable(self, "_on_task_completed"))
	task_area.add_child(task_scene)

func _on_task_completed(points_awarded: int, was_correct: bool):
	# Prevent multiple calls if a scene transition is already in progress
	if transitioning_level:
		return

	var task_key: String
	if current_task_index == 0:
		task_key = "monkey_addition"
	else:
		task_key = "monkey_fruits"

	if points_awarded > 0:
		GameManager.award_points(points_awarded, task_key)

	if hud and hud.has_node("HUDContainer/PointsLabel"):
		hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points

	if monkey:
		if was_correct:
			monkey.texture = load("res://assets/characters/monkey/monkey_neutral.png")
			GameManager.play_correct_sound()
		else:
			monkey.texture = load("res://assets/characters/monkey/monkey_sad.png")
			GameManager.play_incorrect_sound()

	# --- Task Completion Checks ---
	if task_key == "monkey_addition":
		if GameManager.task_points[task_key] >= 300:
			print("✅ Finished Addition Task (Points: %d). Moving to Fruit Sort." % GameManager.task_points[task_key])
			current_task_index += 1
			load_task(current_task_index)
	elif task_key == "monkey_fruits":
		if GameManager.task_points[task_key] >= 300:
			print("✅ Finished Fruit Sort Task (Points: %d). Moving to Level Transition." % GameManager.task_points[task_key])

			transitioning_level = true

			# Stop Monkey Level's background music
			audio_player.stop()

			# Change scene to LevelTransition.tscn
			# The level complete sound will now play in Level_Transition.gd
			await get_tree().create_timer(0.5).timeout # Small delay to ensure prints complete

			if is_instance_valid(self):
				get_tree().change_scene_to_file("res://scenes/levels/LevelTransition.tscn")
			else:
				print("MonkeyLevel node became invalid before scene change could occur.")
