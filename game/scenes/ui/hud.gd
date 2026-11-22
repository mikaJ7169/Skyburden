extends CanvasLayer

signal advance_dialogue
signal note_closed

var dialogue_active := false
var note_active := false
var _box: PanelContainer
var _speaker: Label
var _text: Label
var _fade: ColorRect
var _prompt: Label
var _note_box: PanelContainer
var _note_title: Label
var _note_text: Label

func _ready() -> void:
	GameState.register_ui(self)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0)
	_fade.modulate.a = 1.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)
	LoopManager.loop_started.connect(_on_loop_started)
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
	var note_center := CenterContainer.new()
	note_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(note_center)
	_note_box = PanelContainer.new()
	_note_box.custom_minimum_size = Vector2(420, 0)
	_note_box.visible = false
	note_center.add_child(_note_box)
	var nvb := VBoxContainer.new()
	_note_box.add_child(nvb)
	_note_title = Label.new()
	_note_title.add_theme_font_size_override("font_size", 18)
	nvb.add_child(_note_title)
	_note_text = Label.new()
	_note_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note_text.add_theme_font_size_override("font_size", 14)
	nvb.add_child(_note_text)

func input_blocked() -> bool:
	return dialogue_active or note_active

func set_prompt(text: String) -> void:
	_prompt.text = text

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

func show_note(title: String, text: String) -> void:
	note_active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_note_title.text = title
	_note_text.text = text
	_note_box.visible = true
	await note_closed
	_note_box.visible = false
	note_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if note_active:
		var close := false
		if event is InputEventKey and event.pressed and not event.echo:
			var keys := [Keybinds.key_for("interact"), KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]
			close = event.keycode in keys
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close = true
		if close:
			note_closed.emit()
			get_viewport().set_input_as_handled()
		return
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
