extends CanvasLayer

var _rebind_action := ""
var _buttons := {}

func _ready() -> void:
	GameState.register_menu(self)
	layer = 20
	visible = false
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.65)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	var title := Label.new()
	title.text = "Skyburden"
	title.add_theme_font_size_override("font_size", 20)
	vb.add_child(title)
	var tabs := TabContainer.new()
	vb.add_child(tabs)
	tabs.add_child(_build_game_tab())
	tabs.add_child(_build_keys_tab())

func _build_game_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Jeu"
	var resume := Button.new()
	resume.text = "Reprendre"
	resume.pressed.connect(_on_resume)
	tab.add_child(resume)
	var quit := Button.new()
	quit.text = "Quitter"
	quit.pressed.connect(func() -> void: get_tree().quit())
	tab.add_child(quit)
	return tab

func _build_keys_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Paramètres"
	var hint := Label.new()
	hint.text = "Clique une action, puis appuie sur la nouvelle touche."
	tab.add_child(hint)
	for action in Keybinds.DEFAULTS:
		var row := HBoxContainer.new()
		tab.add_child(row)
		var label := Label.new()
		label.text = Keybinds.LABELS.get(action, action)
		label.custom_minimum_size = Vector2(180, 0)
		row.add_child(label)
		var btn := Button.new()
		btn.text = Keybinds.key_name(action)
		btn.custom_minimum_size = Vector2(140, 0)
		btn.pressed.connect(_on_rebind.bind(action))
		row.add_child(btn)
		_buttons[action] = btn
	return tab

func _on_rebind(action: String) -> void:
	_rebind_action = action
	_buttons[action].text = "Appuie sur une touche…"

func _on_resume() -> void:
	GameState.toggle_menu()

func _refresh_buttons() -> void:
	for action in _buttons:
		_buttons[action].text = Keybinds.key_name(action)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _rebind_action != "":
		if event is InputEventKey and event.pressed and not event.echo:
			Keybinds.set_key(_rebind_action, event.keycode)
			_rebind_action = ""
			_refresh_buttons()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Keybinds.key_for("pause"):
			GameState.toggle_menu()
			get_viewport().set_input_as_handled()
