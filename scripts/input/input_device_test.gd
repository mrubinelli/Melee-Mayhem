extends Node2D

@onready var debug_panel := %DebugPanel
@onready var player := %Player

var _last_input_source := "None"
func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_controller_display()
	debug_panel.set_last_input_source(_last_input_source)
	debug_panel.set_base_speed(player.get_base_speed_units())


func _process(_delta: float) -> void:
	debug_panel.set_left_stick(_get_left_stick_vector())
	debug_panel.set_player_position(player.global_position)
	debug_panel.set_player_bounds(player.get_clamped_player_bounds())
	debug_panel.set_arena_bounds(player.get_arena_bounds())
	debug_panel.set_clamp_active(player.is_clamp_active())
	debug_panel.set_player_speed(player.get_speed_pixels(), player.get_speed_units())
	debug_panel.set_boost_state(player.get_boost_state_name())
	debug_panel.set_boost_time_remaining(player.get_boost_time_remaining())
	debug_panel.set_cooldown_remaining(player.get_cooldown_remaining())
	debug_panel.set_boost_distance(player.get_boost_distance_units())
	debug_panel.set_expected_boost_distance(player.get_expected_boost_distance_units())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_set_last_input_source("Keyboard")
	elif event is InputEventJoypadButton and event.pressed:
		_set_last_input_source("Gamepad")
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.25:
		_set_last_input_source("Gamepad")

	if event.is_action_pressed("toggle_debug"):
		debug_panel.toggle_panel()
		_trigger_feedback("toggle_debug pressed")
	elif event.is_action_pressed("boost"):
		_trigger_feedback("boost pressed")
	elif event.is_action_pressed("reset"):
		player.reset_to_spawn()
		_trigger_feedback("reset pressed")


func _set_last_input_source(source: String) -> void:
	if source == _last_input_source:
		return
	_last_input_source = source
	debug_panel.set_last_input_source(source)


func _trigger_feedback(message: String) -> void:
	debug_panel.show_feedback(message)


func _get_left_stick_vector() -> Vector2:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		return Vector2.ZERO

	var device_id: int = joypads[0]
	return Vector2(
		Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	)


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_controller_display()


func _update_controller_display() -> void:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		debug_panel.set_controller_name("None")
		return

	var names := PackedStringArray()
	for device_id in joypads:
		names.append("%d: %s" % [device_id, Input.get_joy_name(device_id)])
	debug_panel.set_controller_name(", ".join(names))
