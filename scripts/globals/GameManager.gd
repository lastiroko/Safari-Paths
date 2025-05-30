extends Node

var player_points: int = 0  # total, never reset
var current_animal: String = "monkey"
var current_task: int = 0  # 0 = addition, 1 = fruit sort, etc.

# Task progress tracking (optional)
var task_points: Dictionary = {
	"monkey_addition": 0,
	"monkey_fruits": 0,
	"elephant_task1": 0,
	"elephant_task2": 0,
	#"lion_task1": 0, will work on these if we have more time
	#"lion_task2": 0
}

func award_points(amount: int, task_key: String = "") -> void:
	if amount <= 0:
		return
	player_points += amount
	print("💰 Added %d points. Total now: %d" % [amount, player_points])
	if task_key != "" and task_points.has(task_key):
		task_points[task_key] += amount
		print("📌 Task '%s' points: %d" % [task_key, task_points[task_key]])
