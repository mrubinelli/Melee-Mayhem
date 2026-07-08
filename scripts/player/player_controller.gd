extends CharacterBody2D

const DESIGN_UNIT_PIXELS := 100.0
const BASE_SPEED_UNITS := 6.0
const BASE_SPEED_PIXELS := BASE_SPEED_UNITS * DESIGN_UNIT_PIXELS
const ARENA_SIZE_PIXELS := Vector2(2400.0, 2400.0)
const PLAYER_SIZE_PIXELS := Vector2(60.0, 60.0)
const PLAYER_HALF_SIZE_PIXELS := PLAYER_SIZE_PIXELS * 0.5
const MIN_CENTER := (ARENA_SIZE_PIXELS * -0.5) + PLAYER_HALF_SIZE_PIXELS
const MAX_CENTER := (ARENA_SIZE_PIXELS * 0.5) - PLAYER_HALF_SIZE_PIXELS

@export var spawn_position := Vector2.ZERO

var _clamp_active := false
var _input_direction := Vector2.ZERO


func _ready() -> void:
	reset_to_spawn()


func _physics_process(_delta: float) -> void:
	_input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = _input_direction * BASE_SPEED_PIXELS
	move_and_slide()
	_clamp_to_arena()


func reset_to_spawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
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
	return (
		(global_position.x <= MIN_CENTER.x and _input_direction.x < 0.0)
		or (global_position.x >= MAX_CENTER.x and _input_direction.x > 0.0)
		or (global_position.y <= MIN_CENTER.y and _input_direction.y < 0.0)
		or (global_position.y >= MAX_CENTER.y and _input_direction.y > 0.0)
	)


func get_speed_pixels() -> float:
	return velocity.length()


func get_speed_units() -> float:
	return get_speed_pixels() / DESIGN_UNIT_PIXELS


func get_base_speed_units() -> float:
	return BASE_SPEED_UNITS


func get_player_size_pixels() -> Vector2:
	return PLAYER_SIZE_PIXELS


func get_arena_bounds() -> Rect2:
	return Rect2(ARENA_SIZE_PIXELS * -0.5, ARENA_SIZE_PIXELS)


func get_clamped_player_bounds() -> Rect2:
	return Rect2(global_position - PLAYER_HALF_SIZE_PIXELS, PLAYER_SIZE_PIXELS)


func is_clamp_active() -> bool:
	return _clamp_active
