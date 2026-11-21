extends Node3D

const Builder := preload("res://scripts/builder.gd")
const Tex := preload("res://scripts/textures.gd")
const OilLamp := preload("res://scripts/oil_lamp.gd")

const FLOOR_Y := -8.0
const ROOM_MIN := Vector2(-6.0, -2.0)
const ROOM_MAX := Vector2(6.0, 10.0)
const SHAFT_MIN := Vector2(-2.0, 2.0)
const SHAFT_MAX := Vector2(2.0, 8.0)

var _materials := {}

func _ready() -> void:
	_build_room()
	_build_ramp()
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
	var wall := _mat(Color(0.55, 0.55, 0.58), wall_tex)
	var floor_mat := _mat(Color(0.5, 0.5, 0.52), Tex.make_floor())
	var ceil := _mat(Color(0.45, 0.45, 0.48), wall_tex)
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
	var crate := _mat(Color(0.7, 0.6, 0.45), Tex.make_wood())
	Builder.box(self, Vector3(-4.5, FLOOR_Y + 0.5, 0.5), Vector3(1.0, 1.0, 1.0), crate)

func _build_ramp() -> void:
	var run := SHAFT_MAX.y - SHAFT_MIN.y
	var rise := -FLOOR_Y
	var length := sqrt(run * run + rise * rise)
	var angle := atan2(rise, run)
	var center_z := (SHAFT_MIN.y + SHAFT_MAX.y) / 2.0
	var ramp := _mat(Color(0.6, 0.6, 0.62), Tex.make_concrete())
	var width := SHAFT_MAX.x - SHAFT_MIN.x + 0.4
	var ramp_pos := Vector3(0, FLOOR_Y + rise / 2.0, center_z)
	var ramp_size := Vector3(width, 0.4, length + 0.4)
	Builder.box(self, ramp_pos, ramp_size, ramp, Vector3(angle, 0, 0))

func _build_lamp() -> void:
	var lamp := OilLamp.new()
	lamp.position = Vector3(-4.5, FLOOR_Y + 1.0, 0.5)
	add_child(lamp)
