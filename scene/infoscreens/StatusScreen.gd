extends ColorRect

onready var ctl = find_parent("Game").get_node(@"GameLoopController")

func _ready() -> void:
	ctl.connect(
		"stats_updated",
		self,
		"stats_updated")

func stats_updated() -> void:
	$CurrentShiftMoneyLabel.text = "%d¢" % ctl.player_money_current_shift
	$PayoutLabel.text = "%d¢" % ctl.player_money_total
