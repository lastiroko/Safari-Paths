# test/utils/test_helpers.gd
extends RefCounted
class_name TestHelpers

# Helper functions for common test operations

static func simulate_button_click(button: Button) -> void:
	"""Simulate a button click with proper signals"""
	if button and not button.disabled:
		button.pressed.emit()

static func find_button_with_text(container: Node, text: String) -> Button:
	"""Find a button with specific text in a container"""
	for child in container.get_children():
		if child is Button and child.text == text:
			return child
		elif child.get_child_count() > 0:
			var result = find_button_with_text(child, text)
			if result:
				return result
	return null

static func count_enabled_buttons(container: Node) -> int:
	"""Count enabled buttons in a container"""
	var count = 0
	for child in container.get_children():
		if child is Button and not child.disabled:
			count += 1
	return count

static func wait_for_signal_with_timeout(node: Node, signal_name: String, timeout: float = 2.0) -> bool:
	"""Wait for a signal or timeout"""
	var timer = Timer.new()
	node.add_child(timer)
	timer.wait_time = timeout
	timer.one_shot = true
	timer.start()
	
	var signal_received = false
	var signal_callback = func(): signal_received = true
	
	node.connect(signal_name, signal_callback, CONNECT_ONE_SHOT)
	
	while not signal_received and timer.time_left > 0:
		await node.get_tree().process_frame
	
	timer.queue_free()
	return signal_received

static func get_task_completion_percentage(task_key: String) -> float:
	"""Calculate task completion percentage"""
	var required_points = {
		"monkey_addition": 300,
		"monkey_fruits": 300,
		"elephant_task1": 500,
		"elephant_task2": 300
	}
	
	if not required_points.has(task_key):
		return 0.0
	
	var current = GameManager.task_points.get(task_key, 0)
	var required = required_points[task_key]
	
	return (float(current) / float(required)) * 100.0
