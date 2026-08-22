extends CharacterBody3D

# Walk, look, wait. Esc and Q quit. No jump, climb, swim, or HUD.
# Spawn is always the shelf at TideHigh. Never a pocket.
# Clock owns the drop; this does not write it.

const SPEED := 4.0
const LOOK_SENS := 0.002
const SHELF_SPAWN := Vector3(0.0, 2.0, 8.2)

@onready var _camera: Camera3D = $Camera3D


func _ready() -> void:
	# Authored scene can drift. Pin feet to the shelf looking at the waterline.
	global_position = SHELF_SPAWN
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * LOOK_SENS)
		_camera.rotate_x(-event.relative.y * LOOK_SENS)
		_camera.rotation.x = clampf(_camera.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))
	elif event.is_action_pressed("ui_cancel") or _quit_q(event):
		get_tree().quit()
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta

	var input := Vector2(
		_axis(KEY_D, KEY_RIGHT) - _axis(KEY_A, KEY_LEFT),
		_axis(KEY_S, KEY_DOWN) - _axis(KEY_W, KEY_UP)
	)
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()


func _quit_q(event: InputEvent) -> bool:
	return (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.physical_keycode == KEY_Q
	)


func _axis(primary: Key, secondary: Key) -> float:
	return 1.0 if Input.is_physical_key_pressed(primary) or Input.is_physical_key_pressed(secondary) else 0.0
