extends ColorRect

signal notif_finished_hiding()

onready var ctl = find_parent("Game").get_node(@"GameLoopController")

onready var notif_panel: Panel = $NotificationPanel
onready var notif_default_anchors = Vector2(notif_panel.anchor_left, notif_panel.anchor_right)
onready var from_label: Label = $NotificationPanel/FromLabel
onready var body_label: RichTextLabel = $NotificationPanel/BodyLabel
onready var tween: Tween = $Tween

var hiding: bool = false

func _ready() -> void:
	ctl.connect(
		"stats_updated",
		self,
		"stats_updated")
	Notification.connect("show_notif", self, "show_notification")
	Notification.connect("hide_notif", self, "hide_notification")
	tween.connect("tween_all_completed", self, "tween_all_completed")
	connect("notif_finished_hiding", Notification, "next_message")
#	yield(get_tree().create_timer(2.0), "timeout")
#	Notification.push("Bruh", "Bruh")
#	Notification.push("yoink", "yoink")

func stats_updated() -> void:
	$CurrentShiftMoneyLabel.text = "%d¢" % ctl.player_money_current_shift
	$PayoutLabel.text = "%d¢" % ctl.player_money_total

func show_notification(msg) -> void:
	from_label.text = msg.from
	body_label.bbcode_text = msg.body
	notif_panel.anchor_left = notif_default_anchors.x + 1.0
	notif_panel.anchor_right = notif_default_anchors.y + 1.0
	tween.interpolate_property(
		notif_panel,
		"anchor_left",
		notif_default_anchors.x + 1.0,
		notif_default_anchors.x,
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT)
	tween.interpolate_property(
		notif_panel,
		"anchor_right",
		notif_default_anchors.y + 1.0,
		notif_default_anchors.y,
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT)
	tween.start()
	notif_panel.call_deferred("show")

func hide_notification() -> void:
	hiding = true
	tween.interpolate_property(
		notif_panel,
		"anchor_left",
		notif_default_anchors.x,
		notif_default_anchors.x - 1.0,
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN)
	tween.interpolate_property(
		notif_panel,
		"anchor_right",
		notif_default_anchors.y,
		notif_default_anchors.y - 1.0,
		0.5,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN)
	tween.start()

func tween_all_completed() -> void:
	print("all completed, ", hiding)
	if hiding:
		notif_panel.hide()
		hiding = false
		emit_signal("notif_finished_hiding")
