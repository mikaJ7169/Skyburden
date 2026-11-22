extends CanvasLayer

const ITEMS_FILE := "res://data/items.json"
const Icons := preload("res://scripts/icons.gd")

var _list: VBoxContainer

func _ready() -> void:
	GameState.register_inventory(self)
	layer = 15
	visible = false
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
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
	title.text = "Inventaire"
	title.add_theme_font_size_override("font_size", 20)
	vb.add_child(title)
	_list = VBoxContainer.new()
	vb.add_child(_list)
	var hint := Label.new()
	hint.text = Keybinds.key_name("inventory") + " pour fermer."
	vb.add_child(hint)

func refresh() -> void:
	for child in _list.get_children():
		child.queue_free()
	var items: Dictionary = _load_items()
	var count := 0
	for id in items:
		if not MemoryStore.has_flag(StringName(id)):
			continue
		count += 1
		var entry: Dictionary = items[id]
		var kind := String(id).replace("relique_", "").replace("lampe_huile", "lampe")
		var row := HBoxContainer.new()
		_list.add_child(row)
		var icon := TextureRect.new()
		icon.texture = Icons.make_icon(kind)
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP
		row.add_child(icon)
		var texts := VBoxContainer.new()
		row.add_child(texts)
		var name_label := Label.new()
		name_label.text = String(entry.get("name", id))
		name_label.add_theme_font_size_override("font_size", 15)
		texts.add_child(name_label)
		var desc := Label.new()
		desc.text = String(entry.get("desc", ""))
		desc.add_theme_font_size_override("font_size", 12)
		texts.add_child(desc)
	if count == 0:
		var empty := Label.new()
		empty.text = "Vide. Fouille les ruines de Cendreval."
		_list.add_child(empty)

func _load_items() -> Dictionary:
	if not FileAccess.file_exists(ITEMS_FILE):
		return {}
	var f := FileAccess.open(ITEMS_FILE, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Dictionary else {}

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Keybinds.key_for("inventory"):
			GameState.toggle_inventory()
			get_viewport().set_input_as_handled()
