extends CanvasLayer

signal advance_dialogue

var dialogue_active := false
var _timer: Label
var _box: PanelContainer
var _speaker: Label
var _text: Label
var _fade: ColorRect
var _prompt: Label

func _ready() -> void:
	GameState.register_ui(self)
	var vignette := TextureRect.new()
	vignette.texture = _make_vignette()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0)
	_fade.modulate.a = 1.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)
	LoopManager.loop_started.connect(_on_loop_started)
	_timer = Label.new()
	_timer.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_timer.position = Vector2(-150, 8)
	_timer.add_theme_font_size_override("font_size", 16)
	add_child(_timer)
	var cross := Label.new()
	cross.text = "+"
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-4, -10)
	add_child(cross)
	_prompt = Label.new()
	_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.position = Vector2(-160, -60)
	_prompt.add_theme_font_size_override("font_size", 14)
	add_child(_prompt)
	_box = PanelContainer.new()
	_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_box.offset_top = -80
	_box.visible = false
	add_child(_box)
	var vb := VBoxContainer.new()
	_box.add_child(vb)
	_speaker = Label.new()
	_speaker.add_theme_font_size_override("font_size", 14)
	vb.add_child(_speaker)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 14)
	vb.add_child(_text)

func _process(_delta: float) -> void:
	var s := int(LoopManager.remaining_seconds())
	_timer.text = "%02d:%02d  —  boucle %d" % [s / 60, s % 60, GameState.loop_count]

func set_prompt(text: String) -> void:
	_prompt.text = text

func _make_vignette() -> ImageTexture:
	var size := 256
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c := Vector2(size, size) / 2.0
	var max_d := c.length()
	for y in range(size):
		for x in range(size):
			var d := Vector2(x, y).distance_to(c) / max_d
			var a := clampf((d - 0.55) / 0.45, 0.0, 1.0) * 0.45
			img.set_pixel(x, y, Color(0, 0, 0, a))
	return ImageTexture.create_from_image(img)

func _on_loop_started(_index: int) -> void:
	_fade.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 0.0, 3.0)

func play_dialogue(speaker_name: String, lines: Array) -> void:
	dialogue_active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_box.visible = true
	for line in lines:
		_speaker.text = speaker_name
		_text.text = String(line)
		await advance_dialogue
	_box.visible = false
	dialogue_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if not dialogue_active:
		return
	var advance := false
	if event is InputEventKey and event.pressed and not event.echo:
		var keys := [Keybinds.key_for("interact"), KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]
		advance = event.keycode in keys
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = true
	if advance:
		advance_dialogue.emit()
		get_viewport().set_input_as_handled()
