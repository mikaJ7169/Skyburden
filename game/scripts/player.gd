extends CharacterBody3D

const SPEED := 4.5
const MOUSE_SENSITIVITY := 0.0022
const GRAVITY := 12.0

var _spawn_position := Vector3.ZERO
var _spawn_rotation := Vector3.ZERO

@onready var _camera: Camera3D = $Camera3D
@onready var _ray: RayCast3D = $Camera3D/RayCast3D

func _ready() -> void:
	GameState.register_player(self)
	_spawn_position = global_position
	_spawn_rotation = global_rotation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func reset_to_spawn() -> void:
	global_position = _spawn_position
	global_rotation = _spawn_rotation
	velocity = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		_camera.rotation.x = clampf(_camera.rotation.x, -PI / 2.0, PI / 2.0)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_try_interact()
		elif event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _try_interact() -> void:
	if GameState.ui != null and GameState.ui.dialogue_active:
		return
	_ray.force_raycast_update()
	var node: Node = _ray.get_collider() as Node
	while node != null:
		if node.has_method("interact"):
			node.interact()
			return
		node = node.get_parent()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if global_position.y < -30.0:
		reset_to_spawn()
		return
	var input_dir := Vector2.ZERO
	if GameState.ui == null or not GameState.ui.dialogue_active:
		if Input.is_key_pressed(KEY_W):
			input_dir.y -= 1.0
		if Input.is_key_pressed(KEY_S):
			input_dir.y += 1.0
		if Input.is_key_pressed(KEY_A):
			input_dir.x -= 1.0
		if Input.is_key_pressed(KEY_D):
			input_dir.x += 1.0
	var direction := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	if direction.length() > 0.0:
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
	move_and_slide()
