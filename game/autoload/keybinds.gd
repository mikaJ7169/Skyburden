extends Node

const DEFAULTS := {
	"interact": KEY_F,
	"forward": KEY_Z,
	"back": KEY_S,
	"left": KEY_Q,
	"right": KEY_D,
	"fullscreen": KEY_F11,
	"pause": KEY_ESCAPE,
	"inventory": KEY_TAB,
}

const LABELS := {
	"interact": "Interagir",
	"forward": "Avancer",
	"back": "Reculer",
	"left": "Gauche",
	"right": "Droite",
	"fullscreen": "Plein écran",
	"pause": "Menu / pause",
	"inventory": "Inventaire",
}

const SAVE_PATH := "user://keybinds.cfg"

var bindings := {}

func _ready() -> void:
	load_bindings()

func key_for(action: String) -> Key:
	return bindings.get(action, DEFAULTS.get(action, KEY_NONE))

func key_name(action: String) -> String:
	var key := key_for(action)
	if key == KEY_NONE:
		return "—"
	return OS.get_keycode_string(key)

func set_key(action: String, key: Key) -> void:
	for other in bindings:
		if other != action and bindings[other] == key:
			bindings[other] = KEY_NONE
	bindings[action] = key
	save_bindings()

func load_bindings() -> void:
	bindings = DEFAULTS.duplicate()
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		for action in DEFAULTS:
			if cfg.has_section_key("keys", action):
				bindings[action] = cfg.get_value("keys", action)
	else:
		save_bindings()

func save_bindings() -> void:
	var cfg := ConfigFile.new()
	for action in bindings:
		cfg.set_value("keys", action, bindings[action])
	cfg.save(SAVE_PATH)
