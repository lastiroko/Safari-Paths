extends Node

@onready var elephant = $Elephant
@onready var hud = $HUD
@onready var task_area = $Taskarea
@onready var audio_player = $AudioStreamPlayer2D

var current_task_index = 0
var transitioning_level = false # prevent multiple scene change attempts


var task_paths = [
	"res://scenes/tasks/MatchLettersTask.tscn",
	"res://scenes/tasks/SubtractionTask.tscn"
]

func _ready():
	if audio_player:
		if audio_player.stream == null:
			audio_player.stream = preload("res://assets/audio/Kalahari_Dreaming.mp3")
		audio_player.play()
	else:
		print("Warning: AudioStreamPlayer2D node for background music not found in ElephantLevel.")

	load_task(current_task_index)
	if elephant:
		elephant.texture = load("res://assets/characters/elephant/elephant_neutral.png")
	else:
		print("Warning: Elephant node not found in ElephantLevel scene.")



	if hud and hud.has_node("HUDContainer/PointsLabel"):
		hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points
	else:
		print("Warning: HUD or PointsLabel not found in ElephantLevel's _ready().")

func load_task(index: int):
	for child in task_area.get_children():
		child.queue_free()

	var task_scene = load(task_paths[index]).instantiate()
	task_scene.connect("task_completed", Callable(self, "_on_task_completed"))
	task_area.add_child(task_scene)

func _on_task_completed(points_awarded: int, was_correct: bool):
	if transitioning_level:
		return

	var task_key: String
	if current_task_index == 0:
		task_key = "elephant_task1"
	else:
		task_key = "elephant_task2"

	if points_awarded > 0:
		GameManager.award_points(points_awarded, task_key)

	if hud and hud.has_node("HUDContainer/PointsLabel"):
		hud.get_node("HUDContainer/PointsLabel").text = "Points: %d" % GameManager.player_points

	if elephant:
		if was_correct:
			elephant.texture = load("res://assets/characters/elephant/elephant_neutral.png")
			GameManager.play_correct_sound()
		else:
			elephant.texture = load("res://assets/characters/elephant/elephant_sad.png")
			GameManager.play_incorrect_sound()
	else:
		print("Warning: Elephant node missing, cannot update texture or play specific sound.")

	if task_key == "elephant_task1":
		if GameManager.task_points[task_key] >= 500:
			current_task_index += 1
			load_task(current_task_index)
	elif task_key == "elephant_task2":
		if GameManager.task_points[task_key] >= 300:
			transitioning_level = true

			if audio_player:
				audio_player.stop()

			await get_tree().create_timer(0.5).timeout

			if is_instance_valid(self):
				get_tree().change_scene_to_file("res://scenes/levels/EndScene.tscn")
			else:
				print("ElephantLevel node became invalid before scene change could occur.")
