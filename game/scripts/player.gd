extends CharacterBody3D

const SPEED := 4.5
const MOUSE_SENSITIVITY := 0.0022
const GRAVITY := 12.0

var _spawn_position := Vector3.ZERO
var _spawn_rotation := Vector3.ZERO

@onready var _camera: Camera3D = $Camera3D
@onready var _ray: RayCast3D = $Camera3D/RayCast3D
@onready var _lamp_light: OmniLight3D = $LampLight

func _ready() -> void:
	GameState.register_player(self)
	_spawn_position = global_position
	_spawn_rotation = global_rotation
	floor_max_angle = deg_to_rad(60.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func reset_to_spawn() -> void:
	global_position = _spawn_position
	global_rotation = _spawn_rotation
	velocity = Vector3.ZERO
	disable_lamp()

func enable_lamp() -> void:
	_lamp_light.light_energy = 1.2

func disable_lamp() -> void:
	_lamp_light.light_energy = 0.0

func has_lamp() -> bool:
	return _lamp_light.light_energy > 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		_camera.rotation.x = clampf(_camera.rotation.x, -PI / 2.0, PI / 2.0)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Keybinds.key_for("pause"):
			if GameState.ui == null or not GameState.ui.dialogue_active:
				GameState.toggle_menu()
		elif not GameState.menu_open:
			if event.keycode == Keybinds.key_for("interact"):
				_try_interact()
			elif event.keycode == Keybinds.key_for("fullscreen"):
				_toggle_fullscreen()

func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1920, 1080))
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _try_interact() -> void:
	if _ray == null or GameState.menu_open:
		return
	if GameState.ui != null and GameState.ui.dialogue_active:
		return
	_ray.force_raycast_update()
	var node: Node = _ray.get_collider() as Node
	while node != null:
		if node.has_method("interact"):
			node.interact()
			return
		node = node.get_parent()

func _process(_delta: float) -> void:
	if GameState.ui == null:
		return
	if _ray == null or GameState.menu_open:
		GameState.ui.set_prompt("")
		return
	_ray.force_raycast_update()
	var node: Node = _ray.get_collider() as Node
	var text := ""
	while node != null:
		if node.has_method("interact") and node.get("prompt") != null and not node.get("taken"):
			var key := Keybinds.key_name("interact")
			text = "%s — %s" % [key, String(node.get("prompt"))]
			break
		node = node.get_parent()
	GameState.ui.set_prompt(text)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if global_position.y < -30.0:
		reset_to_spawn()
		return
	var input_dir := Vector2.ZERO
	var can_move := not GameState.menu_open
	if GameState.ui != null and GameState.ui.dialogue_active:
		can_move = false
	if can_move:
		if Input.is_key_pressed(Keybinds.key_for("forward")) or Input.is_key_pressed(KEY_W):
			input_dir.y -= 1.0
		if Input.is_key_pressed(Keybinds.key_for("back")) or Input.is_key_pressed(KEY_S):
			input_dir.y += 1.0
		if Input.is_key_pressed(Keybinds.key_for("left")) or Input.is_key_pressed(KEY_A):
			input_dir.x -= 1.0
		if Input.is_key_pressed(Keybinds.key_for("right")) or Input.is_key_pressed(KEY_D):
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
