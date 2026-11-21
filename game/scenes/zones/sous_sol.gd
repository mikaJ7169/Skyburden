extends Node3D

const Builder := preload("res://scripts/builder.gd")
const Tex := preload("res://scripts/textures.gd")
const OilLamp := preload("res://scripts/oil_lamp.gd")

const FLOOR_Y := -8.0
const ROOM_MIN := Vector2(-6.0, -2.0)
const ROOM_MAX := Vector2(6.0, 10.0)
const SHAFT_MIN := Vector2(-2.0, 2.0)
const SHAFT_MAX := Vector2(2.0, 8.0)
const STEPS := 16

var _materials := {}

func _ready() -> void:
	_build_room()
	_build_stairs()
	_build_shelf()
	_build_machine()
	_build_lamp()

func _mat(tint: Color, tex: ImageTexture) -> StandardMaterial3D:
	var key := tint.to_html()
	if not _materials.has(key):
		var m := StandardMaterial3D.new()
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.roughness = 1.0
		m.albedo_color = tint
		m.albedo_texture = tex
		_materials[key] = m
	return _materials[key]

func _build_room() -> void:
	var wall_tex := Tex.make_concrete()
	var wall := _mat(Color(0.5, 0.5, 0.53), wall_tex)
	var floor_mat := _mat(Color(0.5, 0.48, 0.44), Tex.make_dirt())
	var ceil := _mat(Color(0.42, 0.42, 0.45), wall_tex)
	var w := ROOM_MAX.x - ROOM_MIN.x
	var d := ROOM_MAX.y - ROOM_MIN.y
	var cx := (ROOM_MIN.x + ROOM_MAX.x) / 2.0
	var cz := (ROOM_MIN.y + ROOM_MAX.y) / 2.0
	Builder.box(self, Vector3(cx, FLOOR_Y - 0.5, cz), Vector3(w + 1.2, 1.0, d + 1.2), floor_mat)
	var h := -FLOOR_Y
	Builder.box(self, Vector3(cx, -4.0, ROOM_MIN.y), Vector3(w + 1.2, h, 0.6), wall)
	Builder.box(self, Vector3(cx, -4.0, ROOM_MAX.y), Vector3(w + 1.2, h, 0.6), wall)
	Builder.box(self, Vector3(ROOM_MIN.x, -4.0, cz), Vector3(0.6, h, d), wall)
	Builder.box(self, Vector3(ROOM_MAX.x, -4.0, cz), Vector3(0.6, h, d), wall)
	var shaft_cz := (SHAFT_MIN.y + SHAFT_MAX.y) / 2.0
	var shaft_sz := SHAFT_MAX.y - SHAFT_MIN.y
	var north_cz := (ROOM_MIN.y + SHAFT_MIN.y) / 2.0
	var north_sz := SHAFT_MIN.y - ROOM_MIN.y
	Builder.box(self, Vector3(cx, -0.5, north_cz), Vector3(w + 1.2, 1.0, north_sz), ceil)
	var south_cz := (SHAFT_MAX.y + ROOM_MAX.y) / 2.0
	var south_sz := ROOM_MAX.y - SHAFT_MAX.y
	Builder.box(self, Vector3(cx, -0.5, south_cz), Vector3(w + 1.2, 1.0, south_sz), ceil)
	var west_cx := (ROOM_MIN.x + SHAFT_MIN.x) / 2.0
	var west_sx := SHAFT_MIN.x - ROOM_MIN.x
	Builder.box(self, Vector3(west_cx, -0.5, shaft_cz), Vector3(west_sx, 1.0, shaft_sz), ceil)
	var east_cx := (SHAFT_MAX.x + ROOM_MAX.x) / 2.0
	var east_sx := ROOM_MAX.x - SHAFT_MAX.x
	Builder.box(self, Vector3(east_cx, -0.5, shaft_cz), Vector3(east_sx, 1.0, shaft_sz), ceil)

func _build_stairs() -> void:
	var concrete := _mat(Color(0.5, 0.5, 0.52), Tex.make_concrete())
	var run := SHAFT_MAX.y - SHAFT_MIN.y
	var rise := -FLOOR_Y
	var dz := run / STEPS
	var dy := rise / STEPS
	var width := SHAFT_MAX.x - SHAFT_MIN.x
	for i in range(STEPS):
		var z := SHAFT_MAX.y - (i + 0.5) * dz
		var y := FLOOR_Y + (i + 1) * dy - dy / 2.0
		Builder.box(self, Vector3(0, y, z), Vector3(width, dy, dz + 0.02), concrete)
	var h := rise + 0.4
	var mid_z := (SHAFT_MIN.y + SHAFT_MAX.y) / 2.0
	var parapet_l := Vector3(SHAFT_MIN.x - 0.15, FLOOR_Y + h / 2.0, mid_z)
	Builder.box(self, parapet_l, Vector3(0.3, h, run), concrete)
	var parapet_r := Vector3(SHAFT_MAX.x + 0.15, FLOOR_Y + h / 2.0, mid_z)
	Builder.box(self, parapet_r, Vector3(0.3, h, run), concrete)
	var frame := _mat(Color(0.45, 0.45, 0.47), Tex.make_concrete())
	var fw := width + 0.6
	Builder.box(self, Vector3(0, 0.25, SHAFT_MIN.y), Vector3(fw, 0.5, 0.3), frame)
	Builder.box(self, Vector3(0, 0.25, SHAFT_MAX.y), Vector3(fw, 0.5, 0.3), frame)
	Builder.box(self, Vector3(SHAFT_MIN.x, 0.25, mid_z), Vector3(0.3, 0.5, run), frame)
	Builder.box(self, Vector3(SHAFT_MAX.x, 0.25, mid_z), Vector3(0.3, 0.5, run), frame)

func _build_shelf() -> void:
	var wood := _mat(Color(0.55, 0.44, 0.32), Tex.make_wood())
	var pos := Vector3(ROOM_MAX.x - 0.4, FLOOR_Y + 1.5, 4.0)
	Builder.box(self, pos, Vector3(0.4, 3.0, 2.5), wood)
	for i in range(1, 4):
		var y := FLOOR_Y + i * 0.75
		Builder.box(self, Vector3(ROOM_MAX.x - 0.55, y, 4.0), Vector3(0.35, 0.05, 2.5), wood)

func _build_machine() -> void:
	var dark := _mat(Color(0.25, 0.26, 0.3), Tex.make_metal())
	var body := Vector3(3.5, FLOOR_Y + 0.8, -1.4)
	Builder.box(self, body, Vector3(1.4, 1.6, 0.6), dark)
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.albedo_color = Color(0.15, 0.2, 0.15)
	sm.emission_enabled = true
	sm.emission = Color(0.4, 0.8, 0.55)
	sm.emission_energy_multiplier = 1.5
	Builder.box(self, Vector3(3.5, FLOOR_Y + 1.1, -1.05), Vector3(0.6, 0.4, 0.05), sm)
	Builder.cylinder(self, Vector3(3.0, FLOOR_Y + 1.9, -1.4), 0.07, 0.6, dark)
	Builder.cylinder(self, Vector3(4.0, FLOOR_Y + 1.9, -1.4), 0.07, 0.6, dark)

func _build_lamp() -> void:
	var crate := _mat(Color(0.7, 0.6, 0.45), Tex.make_wood())
	Builder.box(self, Vector3(-4.5, FLOOR_Y + 0.5, 0.5), Vector3(1.0, 1.0, 1.0), crate)
	var lamp := OilLamp.new()
	lamp.position = Vector3(-4.5, FLOOR_Y + 1.0, 0.5)
	add_child(lamp)
