extends Node

var loop_count := 0
var player: CharacterBody3D = null
var ui: CanvasLayer = null
var menu: CanvasLayer = null
var menu_open := false

func register_player(p: CharacterBody3D) -> void:
	player = p

func register_ui(u: CanvasLayer) -> void:
	ui = u

func register_menu(m: CanvasLayer) -> void:
	menu = m

func toggle_menu() -> void:
	menu_open = not menu_open
	if menu != null:
		menu.visible = menu_open
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
