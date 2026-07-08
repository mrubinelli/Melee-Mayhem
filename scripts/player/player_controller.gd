extends CharacterBody2D

enum BoostState {
	READY,
	BOOSTING,
	COOLDOWN,
}

const DESIGN_UNIT_PIXELS := 100.0
const BASE_SPEED_UNITS := 6.0
const BASE_SPEED_PIXELS := BASE_SPEED_UNITS * DESIGN_UNIT_PIXELS
const ARENA_SIZE_PIXELS := Vector2(2400.0, 2400.0)
const PLAYER_SIZE_PIXELS := Vector2(60.0, 60.0)
const PLAYER_HALF_SIZE_PIXELS := PLAYER_SIZE_PIXELS * 0.5
const MIN_CENTER := (ARENA_SIZE_PIXELS * -0.5) + PLAYER_HALF_SIZE_PIXELS
const MAX_CENTER := (ARENA_SIZE_PIXELS * 0.5) - PLAYER_HALF_SIZE_PIXELS
const CLAMP_EPSILON_PIXELS := 1.0
const INPUT_DEADZONE := 0.25
const PROFILE_TUNING_PATHS: PackedStringArray = [
	"res://resources/boost/chase_boost_tuning.tres",
	"res://resources/boost/breaker_boost_tuning.tres",
	"res://resources/boost/hurdler_boost_tuning.tres",
	"res://resources/boost/hazardborn_boost_tuning.tres",
	"res://resources/boost/tunneler_boost_tuning.tres",
]

@export var spawn_position := Vector2.ZERO
@export var boost_tuning: BoostTuning

var _clamp_active := false
var _input_direction := Vector2.ZERO
var _intended_velocity := Vector2.ZERO
# Current prototype facing is represented by the last non-zero movement direction.
# Later third-person chase camera work should map this to visible character facing/running direction.
var _facing_direction := Vector2.RIGHT
var _boost_state := BoostState.READY
var _boost_direction := Vector2.RIGHT
var _boost_elapsed := 0.0
var _boost_time_remaining := 0.0
var _cooldown_remaining := 0.0
var _boost_distance_pixels := 0.0
var _profile_index := 0


func _ready() -> void:
	_select_default_profile()
	reset_to_spawn()


func _physics_process(delta: float) -> void:
	_input_direction = _get_movement_direction()
	if not _input_direction.is_zero_approx():
		_facing_direction = _input_direction.normalized()

	_update_boost_state(delta)
	_intended_velocity = _get_target_velocity()
	velocity = _intended_velocity
	var position_before_move := global_position
	move_and_slide()
	_clamp_to_arena()
	if _boost_state == BoostState.BOOSTING:
		_boost_distance_pixels += global_position.distance_to(position_before_move)


func reset_to_spawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_intended_velocity = Vector2.ZERO
	_clear_boost()
	_clamp_to_arena()


func _clamp_to_arena() -> void:
	var unclamped_position := global_position
	global_position = Vector2(
		clampf(global_position.x, MIN_CENTER.x, MAX_CENTER.x),
		clampf(global_position.y, MIN_CENTER.y, MAX_CENTER.y)
	)
	var position_was_clamped := not global_position.is_equal_approx(unclamped_position)
	_clamp_active = position_was_clamped or _is_pushing_against_clamp()
	if position_was_clamped:
		velocity = Vector2.ZERO


func _is_pushing_against_clamp() -> bool:
	var player_bounds := get_clamped_player_bounds()
	var arena_bounds := get_arena_bounds()
	var player_left := player_bounds.position.x
	var player_right := player_bounds.position.x + player_bounds.size.x
	var player_top := player_bounds.position.y
	var player_bottom := player_bounds.position.y + player_bounds.size.y
	var arena_left := arena_bounds.position.x
	var arena_right := arena_bounds.position.x + arena_bounds.size.x
	var arena_top := arena_bounds.position.y
	var arena_bottom := arena_bounds.position.y + arena_bounds.size.y

	return (
		(player_left <= arena_left + CLAMP_EPSILON_PIXELS and _intended_velocity.x < 0.0)
		or (player_right >= arena_right - CLAMP_EPSILON_PIXELS and _intended_velocity.x > 0.0)
		or (player_top <= arena_top + CLAMP_EPSILON_PIXELS and _intended_velocity.y < 0.0)
		or (player_bottom >= arena_bottom - CLAMP_EPSILON_PIXELS and _intended_velocity.y > 0.0)
	)


func get_speed_pixels() -> float:
	return velocity.length()


func get_speed_units() -> float:
	return get_speed_pixels() / DESIGN_UNIT_PIXELS


func get_base_speed_units() -> float:
	return BASE_SPEED_UNITS


func get_profile_name() -> String:
	if boost_tuning == null:
		return "None"

	return boost_tuning.profile_name


func get_boost_duration() -> float:
	return boost_tuning.duration if boost_tuning != null else 0.0


func get_boost_top_speed_units() -> float:
	return boost_tuning.top_speed_units if boost_tuning != null else 0.0


func get_boost_acceleration_time() -> float:
	return boost_tuning.time_to_top_speed if boost_tuning != null else 0.0


func get_boost_cooldown() -> float:
	return boost_tuning.cooldown if boost_tuning != null else 0.0


func get_boost_steering_strength() -> float:
	return boost_tuning.steering_strength if boost_tuning != null else 0.0


func get_player_size_pixels() -> Vector2:
	return PLAYER_SIZE_PIXELS


func get_arena_bounds() -> Rect2:
	return Rect2(ARENA_SIZE_PIXELS * -0.5, ARENA_SIZE_PIXELS)


func get_clamped_player_bounds() -> Rect2:
	return Rect2(global_position - PLAYER_HALF_SIZE_PIXELS, PLAYER_SIZE_PIXELS)


func is_clamp_active() -> bool:
	return _clamp_active


func get_boost_state_name() -> String:
	match _boost_state:
		BoostState.BOOSTING:
			return "boosting"
		BoostState.COOLDOWN:
			return "cooldown"
		_:
			return "ready"


func get_boost_time_remaining() -> float:
	return _boost_time_remaining


func get_cooldown_remaining() -> float:
	return _cooldown_remaining


func get_boost_distance_units() -> float:
	return _boost_distance_pixels / DESIGN_UNIT_PIXELS


func get_expected_boost_distance_units() -> float:
	if boost_tuning == null:
		return 0.0

	var duration: float = maxf(boost_tuning.duration, 0.0)
	var top_speed: float = maxf(boost_tuning.top_speed_units, 0.0)
	var acceleration_time: float = maxf(boost_tuning.time_to_top_speed, 0.0)
	if duration <= 0.0:
		return 0.0
	if acceleration_time <= 0.0:
		return top_speed * duration

	var ramp_time: float = minf(acceleration_time, duration)
	var ramp_end_ratio := ramp_time / acceleration_time
	var ramp_end_speed := lerpf(BASE_SPEED_UNITS, top_speed, ramp_end_ratio)
	var acceleration_distance: float = ((BASE_SPEED_UNITS + ramp_end_speed) * 0.5) * ramp_time
	var full_speed_distance: float = top_speed * maxf(duration - ramp_time, 0.0)
	return acceleration_distance + full_speed_distance


func switch_to_next_profile() -> void:
	if PROFILE_TUNING_PATHS.is_empty():
		return

	_profile_index = wrapi(_profile_index + 1, 0, PROFILE_TUNING_PATHS.size())
	_load_profile_tuning(_profile_index)
	_clear_boost_for_profile_switch()


func _get_movement_direction() -> Vector2:
	var keyboard_direction := _get_keyboard_direction()
	if not keyboard_direction.is_zero_approx():
		return keyboard_direction

	var gamepad_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if gamepad_direction.length() < INPUT_DEADZONE:
		return Vector2.ZERO

	return gamepad_direction


func _get_keyboard_direction() -> Vector2:
	var keyboard_direction := Vector2(
		_get_keyboard_action_strength("move_right") - _get_keyboard_action_strength("move_left"),
		_get_keyboard_action_strength("move_down") - _get_keyboard_action_strength("move_up")
	)
	if keyboard_direction.length() > 1.0:
		return keyboard_direction.normalized()

	return keyboard_direction


func _get_keyboard_action_strength(action_name: StringName) -> float:
	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if key_event.physical_keycode != 0 and Input.is_physical_key_pressed(key_event.physical_keycode):
				return 1.0
			if key_event.physical_keycode == 0 and Input.is_key_pressed(key_event.keycode):
				return 1.0

	return 0.0


func _update_boost_state(delta: float) -> void:
	match _boost_state:
		BoostState.READY:
			if Input.is_action_just_pressed("boost") and boost_tuning != null:
				_start_boost()
		BoostState.BOOSTING:
			_boost_elapsed += delta
			_boost_time_remaining = maxf(_boost_time_remaining - delta, 0.0)
			if _boost_time_remaining <= 0.0:
				_start_cooldown()
		BoostState.COOLDOWN:
			_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
			if _cooldown_remaining <= 0.0:
				_boost_state = BoostState.READY


func _get_target_velocity() -> Vector2:
	if _boost_state != BoostState.BOOSTING or boost_tuning == null:
		return _input_direction * BASE_SPEED_PIXELS

	if not _input_direction.is_zero_approx():
		var steer_weight: float = clampf(boost_tuning.steering_strength, 0.0, 1.0)
		var target_direction := _input_direction.normalized()
		_boost_direction = _steer_boost_direction(_boost_direction, target_direction, steer_weight)

	var speed_units := _get_current_boost_speed_units()
	return _boost_direction * speed_units * DESIGN_UNIT_PIXELS


func _steer_boost_direction(current_direction: Vector2, target_direction: Vector2, steer_weight: float) -> Vector2:
	if steer_weight <= 0.0:
		return current_direction
	if steer_weight >= 1.0:
		return target_direction

	var current := current_direction.normalized()
	var target := target_direction.normalized()
	if current.is_zero_approx():
		return target

	if current.dot(target) <= -0.9999:
		return current.rotated(PI * steer_weight).normalized()

	return current.slerp(target, steer_weight).normalized()


func _get_current_boost_speed_units() -> float:
	var top_speed: float = maxf(boost_tuning.top_speed_units, 0.0)
	var acceleration_time: float = maxf(boost_tuning.time_to_top_speed, 0.0)
	if acceleration_time <= 0.0:
		return top_speed

	var acceleration_ratio: float = clampf(_boost_elapsed / acceleration_time, 0.0, 1.0)
	return lerpf(BASE_SPEED_UNITS, top_speed, acceleration_ratio)


func _start_boost() -> void:
	_boost_state = BoostState.BOOSTING
	_boost_elapsed = 0.0
	_boost_time_remaining = maxf(boost_tuning.duration, 0.0)
	_cooldown_remaining = 0.0
	_boost_distance_pixels = 0.0

	# Boost uses active movement input first; neutral boost uses current facing.
	if not _input_direction.is_zero_approx():
		_boost_direction = _input_direction.normalized()
	elif not _facing_direction.is_zero_approx():
		_boost_direction = _facing_direction.normalized()
	else:
		_boost_direction = Vector2.RIGHT

	if _boost_time_remaining <= 0.0:
		_start_cooldown()


func _start_cooldown() -> void:
	_boost_state = BoostState.COOLDOWN
	_boost_time_remaining = 0.0
	_cooldown_remaining = maxf(boost_tuning.cooldown, 0.0)
	if _cooldown_remaining <= 0.0:
		_boost_state = BoostState.READY


func _clear_boost() -> void:
	_boost_state = BoostState.READY
	_boost_direction = Vector2.RIGHT
	_boost_elapsed = 0.0
	_boost_time_remaining = 0.0
	_cooldown_remaining = 0.0
	_boost_distance_pixels = 0.0


func _clear_boost_for_profile_switch() -> void:
	_boost_state = BoostState.READY
	_boost_direction = _facing_direction.normalized() if not _facing_direction.is_zero_approx() else Vector2.RIGHT
	_boost_elapsed = 0.0
	_boost_time_remaining = 0.0
	_cooldown_remaining = 0.0
	_boost_distance_pixels = 0.0
	_intended_velocity = Vector2.ZERO
	velocity = Vector2.ZERO


func _select_default_profile() -> void:
	if PROFILE_TUNING_PATHS.is_empty():
		return

	_profile_index = 0
	_load_profile_tuning(_profile_index)


func _load_profile_tuning(profile_index: int) -> void:
	var loaded_resource := load(PROFILE_TUNING_PATHS[profile_index])
	if loaded_resource is BoostTuning:
		boost_tuning = loaded_resource
