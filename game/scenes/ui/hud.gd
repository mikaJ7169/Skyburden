extends CanvasLayer

signal advance_dialogue

var dialogue_active := false
var _timer: Label
var _box: PanelContainer
var _speaker: Label
var _text: Label

func _ready() -> void:
	GameState.register_ui(self)
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
		advance = event.keycode in [KEY_E, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = true
	if advance:
		advance_dialogue.emit()
		get_viewport().set_input_as_handled()
