extends ColorRect

onready var ctl = find_parent("Game").get_node(@"GameLoopController")

func _ready() -> void:
	ctl.connect(
		"stats_updated",
		self,
		"stats_updated")

func stats_updated() -> void:
	$AssembliesFinishedLabel.text = str(ctl.player_assembled_current_shift)
	$PartsAttachedLabel.text = str(ctl.player_attachments_current_shift)
