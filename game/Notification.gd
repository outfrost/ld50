extends Node

# Example:
# ```
# Notification.push("Line Manager", "Press that big green button!")
# ```

func push(from: String, body: String) -> void:
	print("NOTIFICATION FROM " + from + ": " + body)
	# TODO Actually push notifications to screen
