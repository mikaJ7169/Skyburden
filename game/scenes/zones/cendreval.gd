extends Node3D

const Builder := preload("res://scripts/builder.gd")
const Tex := preload("res://scripts/textures.gd")

const CITY_HALF := 58.0
const SHAFT_MIN := Vector2(-2.0, 2.0)
const SHAFT_MAX := Vector2(2.0, 8.0)
const BLOCK_POSITIONS := [10.0, 30.0, 50.0, -10.0, -30.0, -50.0]
const RED := Color(0.62, 0.10, 0.07)
const NEON := Color(0.55, 0.85, 0.65)

var _rng := RandomNumberGenerator.new()
var _materials := {}
var _tex := {}

func _ready() -> void:
	_rng.seed = 2200
	_tex = {
		"stone": Tex.make_stone(),
		"brick": Tex.make_brick(),
		"concrete": Tex.make_concrete(),
		"floor": Tex.make_floor(),
		"wood": Tex.make_wood(),
		"metal": Tex.make_metal(),
	}
	_build_ground()
	_build_auberge()
	_build_blocks()
	_build_lamps()
	_build_pillars()
	_build_doors()
	_build_rubble()
	_build_border()
	_build_floating()

func _mat(tint: Color, tex_name := "", emission := false) -> StandardMaterial3D:
	var key := tint.to_html() + "|" + tex_name + ("|e" if emission else "")
	if not _materials.has(key):
		var m := StandardMaterial3D.new()
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.roughness = 1.0
		m.albedo_color = tint
		if tex_name != "" and _tex.has(tex_name):
			m.albedo_texture = _tex[tex_name]
		if emission:
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.emission_enabled = true
			m.emission = tint
			m.emission_energy_multiplier = 1.5
		_materials[key] = m
	return _materials[key]

func _box(
	pos: Vector3, size: Vector3, tint: Color, tex_name := "", emission := false, rot := Vector3.ZERO
) -> StaticBody3D:
	return Builder.box(self, pos, size, _mat(tint, tex_name, emission), rot)

func _in_shaft(x: float, z: float, margin: float) -> bool:
	var in_x := x >= SHAFT_MIN.x - margin and x <= SHAFT_MAX.x + margin
	var in_z := z >= SHAFT_MIN.y - margin and z <= SHAFT_MAX.y + margin
	return in_x and in_z

func _build_ground() -> void:
	var t := Color(0.85, 0.85, 0.87)
	Builder.box(self, Vector3(0, -0.5, -28.0), Vector3(116.0, 1.0, 60.0), _mat(t, "floor"))
	Builder.box(self, Vector3(0, -0.5, 33.0), Vector3(116.0, 1.0, 50.0), _mat(t, "floor"))
	Builder.box(self, Vector3(-30.0, -0.5, 5.0), Vector3(56.0, 1.0, 6.0), _mat(t, "floor"))
	Builder.box(self, Vector3(30.0, -0.5, 5.0), Vector3(56.0, 1.0, 6.0), _mat(t, "floor"))

func _build_auberge() -> void:
	var cz := -6.0
	var h := 3.5
	var wall := _mat(Color(0.85, 0.82, 0.78), "brick")
	Builder.box(self, Vector3(0, h / 2.0, cz - 5.0), Vector3(10.0, h, 0.6), wall)
	Builder.box(self, Vector3(0, h / 2.0, cz + 5.0), Vector3(10.0, h, 0.6), wall)
	Builder.box(self, Vector3(-5.0, h / 2.0, cz), Vector3(0.6, h, 10.0), wall)
	Builder.box(self, Vector3(5.0, h / 2.0, cz), Vector3(0.6, h, 10.0), wall)
	var slab_mat := _mat(Color(0.5, 0.5, 0.52), "concrete")
	var slab_pos := Vector3(0.4, 7.0, cz - 0.6)
	Builder.box(self, slab_pos, Vector3(10.0, 0.4, 10.0), slab_mat, Vector3(0, 0, 0.22))

func _build_blocks() -> void:
	for bx: float in BLOCK_POSITIONS:
		for bz: float in BLOCK_POSITIONS:
			if absf(bx) <= 12.0 and absf(bz) <= 12.0:
				continue
			if _rng.randf() < 0.25:
				continue
			var w: float = _rng.randf_range(8.0, 12.0)
			var d: float = _rng.randf_range(8.0, 12.0)
			var h: float = _rng.randf_range(5.0, 13.0)
			var px: float = bx + _rng.randf_range(-1.0, 1.0)
			var pz: float = bz + _rng.randf_range(-1.0, 1.0)
			var tex_name := "stone" if _rng.randf() < 0.7 else "brick"
			var tint := Color(0.85, 0.84, 0.82) if tex_name == "stone" else Color(0.9, 0.85, 0.82)
			var ruined := _rng.randf() < 0.4
			if ruined:
				h *= 0.45
			var rot := Vector3.ZERO
			if ruined:
				rot = Vector3(0, 0, _rng.randf_range(-0.1, 0.1))
			_box(Vector3(px, h / 2.0, pz), Vector3(w, h, d), tint, tex_name, false, rot)
			if ruined:
				var slab_pos := Vector3(px + w * 0.4, h + 1.2, pz - d * 0.3)
				var slab_rot := Vector3(0, 0, _rng.randf_range(-0.3, 0.3))
				var slab_tint := Color(0.6, 0.6, 0.62)
				_box(slab_pos, Vector3(w * 0.6, 0.4, d * 0.6), slab_tint, "concrete", false, slab_rot)

func _build_lamps() -> void:
	var spots := [
		Vector2(20, 20), Vector2(-20, 20), Vector2(20, -20), Vector2(-20, -20),
		Vector2(40, 0), Vector2(-40, 0), Vector2(0, 40), Vector2(0, -40),
		Vector2(40, 40), Vector2(-40, -40), Vector2(40, -40), Vector2(-40, 40),
	]
	for s in spots:
		_box(Vector3(s.x, 2.25, s.y), Vector3(0.18, 4.5, 0.18), Color(0.5, 0.52, 0.56), "metal")
		_box(Vector3(s.x, 4.6, s.y), Vector3(0.55, 0.3, 0.55), NEON, "", true)

func _build_pillars() -> void:
	var spots := [
		Vector2(0, -20), Vector2(0, 20), Vector2(-20, 0),
		Vector2(20, 0), Vector2(-40, 0), Vector2(40, 0),
	]
	for s in spots:
		if _in_shaft(s.x, s.y, 2.0):
			continue
		_box(Vector3(s.x, 3.0, s.y), Vector3(1.2, 6.0, 1.2), Color(0.7, 0.7, 0.72), "concrete")

func _build_doors() -> void:
	_make_door(Vector3(0, 0, -30), Vector3(0, PI / 2.0, 0))
	_make_door(Vector3(30, 0, 0), Vector3.ZERO)

func _make_door(pos: Vector3, rot: Vector3) -> void:
	var pivot := Node3D.new()
	pivot.position = pos
	pivot.rotation = rot
	add_child(pivot)
	var jamb := _mat(Color(0.8, 0.79, 0.76), "concrete")
	var door := _mat(Color(0.9, 0.85, 0.75), "wood")
	Builder.box(pivot, Vector3(-0.95, 1.5, 0), Vector3(0.3, 3.0, 0.4), jamb)
	Builder.box(pivot, Vector3(0.95, 1.5, 0), Vector3(0.3, 3.0, 0.4), jamb)
	Builder.box(pivot, Vector3(0, 3.1, 0), Vector3(2.2, 0.4, 0.4), jamb)
	Builder.box(pivot, Vector3(0, 1.35, 0), Vector3(1.7, 2.7, 0.12), door)

func _build_rubble() -> void:
	for i in range(10):
		var cx := _rng.randf_range(-52.0, 52.0)
		var cz := _rng.randf_range(-52.0, 52.0)
		if _in_shaft(cx, cz, 2.0):
			continue
		for j in range(5):
			var s := _rng.randf_range(0.4, 1.3)
			var dx := _rng.randf_range(-1.2, 1.2)
			var dz := _rng.randf_range(-1.2, 1.2)
			var tilt := Vector3(0, 0, _rng.randf_range(-0.5, 0.5))
			var tint := Color(0.55, 0.55, 0.57)
			_box(Vector3(cx + dx, s / 2.0, cz + dz), Vector3(s, s, s), tint, "concrete", false, tilt)

func _build_border() -> void:
	var len := CITY_HALF * 2.0
	_box(Vector3(0, 0.15, -CITY_HALF), Vector3(len, 0.3, 0.4), RED, "", true)
	_box(Vector3(0, 0.15, CITY_HALF), Vector3(len, 0.3, 0.4), RED, "", true)
	_box(Vector3(-CITY_HALF, 0.15, 0), Vector3(0.4, 0.3, len), RED, "", true)
	_box(Vector3(CITY_HALF, 0.15, 0), Vector3(0.4, 0.3, len), RED, "", true)
	for i in range(14):
		var side := _rng.randi_range(0, 3)
		var along := _rng.randf_range(-CITY_HALF, CITY_HALF)
		var y := _rng.randf_range(10.0, 48.0)
		var out := _rng.randf_range(2.0, 14.0)
		var pos := Vector3.ZERO
		match side:
			0:
				pos = Vector3(along, y, -CITY_HALF - out)
			1:
				pos = Vector3(along, y, CITY_HALF + out)
			2:
				pos = Vector3(-CITY_HALF - out, y, along)
			3:
				pos = Vector3(CITY_HALF + out, y, along)
		var s := _rng.randf_range(1.5, 5.0)
		var tint := Color(0.6, 0.6, 0.62)
		var tilt := Vector3(0, 0, _rng.randf_range(-0.4, 0.4))
		_box(pos, Vector3(s, s * _rng.randf_range(0.5, 1.0), s), tint, "concrete", false, tilt)

func _build_floating() -> void:
	for i in range(3):
		var s := _rng.randf_range(2.0, 4.0)
		var x := _rng.randf_range(-40.0, 40.0)
		var z := _rng.randf_range(-40.0, 40.0)
		if _in_shaft(x, z, 3.0):
			continue
		var tilt := Vector3(0, 0, _rng.randf_range(-0.4, 0.4))
		var y := _rng.randf_range(18.0, 30.0)
		var tint := Color(0.6, 0.6, 0.62)
		_box(Vector3(x, y, z), Vector3(s, s * 0.6, s), tint, "concrete", false, tilt)
