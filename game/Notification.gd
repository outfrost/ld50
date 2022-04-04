extends Node

# Example:
# ```
# Notification.push("Line Manager", "Press that big green button!")
# ```

signal hide_notif()
signal show_notif(msg)

class Message:
	var from: String
	var body: String

	func _init(from: String, body: String) -> void:
		self.from = from
		self.body = body

onready var timer: Timer = $Timer

var queue: Array = []
var hiding: bool = false

func _ready() -> void:
	timer.connect("timeout", self, "hide_message")

func push(from: String, body: String) -> void:
	queue.append(Message.new(from, body))
	if timer.is_stopped() && !hiding:
		next_message()

func clear_queue() -> void:
	queue.clear()

func hide_message() -> void:
	emit_signal("hide_notif")
	hiding = true

func next_message() -> void:
	hiding = false
	var msg = queue.pop_front()
	if msg:
		emit_signal("show_notif", msg)
		timer.start()
