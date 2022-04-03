extends Control


var display_shown:bool = false
var display_busy:bool = false


func _ready():
	self.visible = false

func _input(event):
	if event.is_action_pressed("test_action_a") and !display_shown and !display_busy:
		self.visible = true
		display_busy = true
		display_shown = true
		animplayer.play("Display-In")
		yield(get_tree().create_timer(1.0), "timeout")
		display_busy = false

	if event.is_action_pressed("test_action_b") and display_shown and !display_busy:
		display_busy = true
		display_shown = false
		animplayer.play("Display-Out")
		yield(get_tree().create_timer(1.0), "timeout")
		self.visible = false
		display_busy = false
