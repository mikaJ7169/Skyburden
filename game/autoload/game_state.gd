extends Node

var loop_count := 0
var player: CharacterBody3D = null
var ui: CanvasLayer = null
var menu: CanvasLayer = null
var inventory: CanvasLayer = null
var menu_open := false
var inventory_open := false

func register_player(p: CharacterBody3D) -> void:
	player = p

func register_ui(u: CanvasLayer) -> void:
	ui = u

func register_menu(m: CanvasLayer) -> void:
	menu = m

func register_inventory(inv: CanvasLayer) -> void:
	inventory = inv

func toggle_menu() -> void:
	menu_open = not menu_open
	if menu != null:
		menu.visible = menu_open
	_update_mouse_mode()

func toggle_inventory() -> void:
	inventory_open = not inventory_open
	if inventory != null:
		inventory.visible = inventory_open
		if inventory_open:
			inventory.refresh()
	_update_mouse_mode()

func _update_mouse_mode() -> void:
	if menu_open or inventory_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
