extends CanvasLayer

@onready var controller_label: Label = %ControllerLabel
@onready var stick_label: Label = %StickLabel
@onready var source_label: Label = %SourceLabel
@onready var position_label: Label = %PositionLabel
@onready var bounds_label: Label = %BoundsLabel
@onready var arena_bounds_label: Label = %ArenaBoundsLabel
@onready var clamp_label: Label = %ClampLabel
@onready var speed_label: Label = %SpeedLabel
@onready var base_speed_label: Label = %BaseSpeedLabel
@onready var feedback_label: Label = %FeedbackLabel

var _feedback_time := 0.0


func _process(delta: float) -> void:
	if _feedback_time > 0.0:
		_feedback_time = maxf(_feedback_time - delta, 0.0)
		if _feedback_time == 0.0:
			feedback_label.text = "Feedback: waiting"


func set_controller_name(controller_name: String) -> void:
	controller_label.text = "Controller: %s" % controller_name


func set_left_stick(stick: Vector2) -> void:
	stick_label.text = "Left stick: (%.2f, %.2f)" % [stick.x, stick.y]


func set_last_input_source(source: String) -> void:
	source_label.text = "Last input source: %s" % source


func set_player_position(player_position: Vector2) -> void:
	position_label.text = "Player position: (%.1f, %.1f) px" % [player_position.x, player_position.y]


func set_player_bounds(player_bounds: Rect2) -> void:
	var left := player_bounds.position.x
	var right := player_bounds.position.x + player_bounds.size.x
	var top := player_bounds.position.y
	var bottom := player_bounds.position.y + player_bounds.size.y
	bounds_label.text = "Player bounds: L %.1f R %.1f T %.1f B %.1f" % [left, right, top, bottom]


func set_arena_bounds(arena_bounds: Rect2) -> void:
	var left := arena_bounds.position.x
	var right := arena_bounds.position.x + arena_bounds.size.x
	var top := arena_bounds.position.y
	var bottom := arena_bounds.position.y + arena_bounds.size.y
	arena_bounds_label.text = "Arena bounds: L %.1f R %.1f T %.1f B %.1f" % [left, right, top, bottom]


func set_clamp_active(is_active: bool) -> void:
	clamp_label.text = "Clamp active: %s" % ("yes" if is_active else "no")


func set_player_speed(speed_pixels: float, speed_units: float) -> void:
	speed_label.text = "Current speed: %.1f px/s (%.2f u/s)" % [speed_pixels, speed_units]


func set_base_speed(base_speed_units: float) -> void:
	base_speed_label.text = "Base speed: %.2f u/s" % base_speed_units


func toggle_panel() -> void:
	visible = not visible


func show_feedback(message: String) -> void:
	feedback_label.text = "Feedback: %s" % message
	_feedback_time = 1.0
