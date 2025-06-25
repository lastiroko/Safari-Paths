extends Node

var player_points: int = 0  # total, never reset
var current_animal: String = "monkey"
var current_task: int = 0   # 0 = addition, 1 = fruit sort, etc.

#task progress tracking
var task_points: Dictionary = {
	"monkey_addition": 0,
	"monkey_fruits": 0,
	"elephant_task1": 0,
	"elephant_task2": 0,
	#"lion_task1": 0, # will work on these if we have more time
	#"lion_task2": 0
}

@onready var audio_button_click = $AudioButtonClick
@onready var audio_correct_answer = $AudioCorrectAnswer
@onready var audio_incorrect_answer = $AudioIncorrectAnswer
@onready var audio_level_complete = $AudioLevelComplete
@onready var audio_background_music = $AudioBackgroundMusic # entry screen bg music

func _ready():
	# firebase for future storage
	pass

func award_points(amount: int, task_key: String = "") -> void:
	if amount <= 0:
		return
	player_points += amount
	print("💰 Added %d points. Total now: %d" % [amount, player_points])
	if task_key != "" and task_points.has(task_key):
		task_points[task_key] += amount
		print("📌 Task '%s' points: %d" % [task_key, task_points[task_key]])

# --- Function to Reset Game State ---
func reset_game_state():
	player_points = 0
	current_animal = "monkey" # Always start from monkey level after reset
	current_task = 0

	# Crucially, reset all task points to 0
	task_points = {
		"monkey_addition": 0,
		"monkey_fruits": 0,
		"elephant_task1": 0,
		"elephant_task2": 0,
		# Add any other task keys here if you expand the game
	}
	print("Game state reset.")

# --- Sound Playback Functions ---
func play_button_click_sound():
	if audio_button_click and audio_button_click.stream != null:
		audio_button_click.play()
	#else:
		#print("Warning: AudioButtonClick not set up in GameManager.")

func play_correct_sound():
	if audio_correct_answer and audio_correct_answer.stream != null:
		audio_correct_answer.play()
	#else:
		#print("Warning: AudioCorrectAnswer not set up in GameManager.")

func play_incorrect_sound():
	if audio_incorrect_answer and audio_incorrect_answer.stream != null:
		audio_incorrect_answer.play()
	#else:
		#print("Warning: AudioIncorrectAnswer not set up in GameManager.")

func play_level_complete_sound():
	if audio_level_complete and audio_level_complete.stream != null:
		audio_level_complete.play()
	#else:
		#print("Warning: AudioLevelComplete not set up in GameManager.")

func play_background_music():
	if audio_background_music and audio_background_music.stream != null and not audio_background_music.playing:
		audio_background_music.play()
	#else:
		#print("Warning: AudioBackgroundMusic not set up or already playing in GameManager.")

func stop_background_music():
	if audio_background_music and audio_background_music.playing:
		audio_background_music.stop()
