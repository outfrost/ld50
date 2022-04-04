extends ColorRect

onready var shift_timer: Timer = find_parent("Game").get_node(@"GameLoopController/ShiftTimer")

func _process(delta: float) -> void:
	$TimeLeftLabel.text = "%02d:%02d.%03d" % [
		int(shift_timer.time_left) / 60,
		int(shift_timer.time_left) % 60,
		int(shift_timer.time_left * 1000.0) % 1000
	]
