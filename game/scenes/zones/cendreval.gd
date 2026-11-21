extends Node3D

const Builder := preload("res://scripts/builder.gd")
const Tex := preload("res://scripts/textures.gd")
const SkyManager := preload("res://scripts/sky_manager.gd")
const Relic := preload("res://scripts/relic.gd")

const CITY_HALF := 58.0
const SHAFT_MIN := Vector2(-2.0, 2.0)
const SHAFT_MAX := Vector2(2.0, 8.0)
const BLOCK_POSITIONS := [10.0, 30.0, 50.0, -10.0, -30.0, -50.0]
const RED := Color(0.62, 0.10, 0.07)
const NEON := Color(0.55, 0.85, 0.65)
const WARM := Color(1.0, 0.75, 0.45)

var _rng := RandomNumberGenerator.new()
var _materials := {}
var _tex := {}
var _debris: Array = []
var _lamp_lights: Array = []

func _ready() -> void:
	_rng.seed = 2200
	_tex = {
		"stone": Tex.make_stone(),
		"brick": Tex.make_brick(),
		"concrete": Tex.make_concrete(),
		"floor": Tex.make_floor(),
		"wood": Tex.make_wood(),
		"metal": Tex.make_metal(),
		"roof": Tex.make_roof(),
	}
	_build_ground()
	_build_auberge()
	_build_houses()
	_build_lamps()
	_build_pillars()
	_build_doors()
	_build_props()
	_build_rubble()
	_build_border()
	_build_floating()
	_build_pickups()

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

func _cyl(
	pos: Vector3, radius: float, height: float, tint: Color, tex_name := "", rot := Vector3.ZERO
) -> StaticBody3D:
	return Builder.cylinder(self, pos, radius, height, _mat(tint, tex_name), rot)

func _in_shaft(x: float, z: float, margin: float) -> bool:
	var in_x := x >= SHAFT_MIN.x - margin and x <= SHAFT_MAX.x + margin
	var in_z := z >= SHAFT_MIN.y - margin and z <= SHAFT_MAX.y + margin
	return in_x and in_z

func _street_pos() -> Vector3:
	var lines := [0.0, 20.0, -20.0, 40.0, -40.0]
	var axis := _rng.randi_range(0, 1)
	var line: float = lines[_rng.randi_range(0, lines.size() - 1)]
	var along := _rng.randf_range(-52.0, 52.0)
	var jitter := _rng.randf_range(-2.0, 2.0)
	var x := line + jitter if axis == 0 else along
	var z := along if axis == 0 else line + jitter
	if _in_shaft(x, z, 2.5):
		return Vector3.ZERO
	return Vector3(x, 0.0, z)

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
	Builder.box(self, Vector3(-3.0, h / 2.0, cz + 5.0), Vector3(4.0, h, 0.6), wall)
	Builder.box(self, Vector3(3.0, h / 2.0, cz + 5.0), Vector3(4.0, h, 0.6), wall)
	Builder.box(self, Vector3(-5.0, h / 2.0, cz), Vector3(0.6, h, 10.0), wall)
	Builder.box(self, Vector3(5.0, h / 2.0, cz), Vector3(0.6, h, 10.0), wall)
	var slab_mat := _mat(Color(0.55, 0.52, 0.48), "roof")
	var slab_pos := Vector3(0.4, 6.6, cz - 0.6)
	Builder.box(self, slab_pos, Vector3(10.5, 0.3, 10.5), slab_mat, Vector3(0, 0, 0.22))
	var chim := _mat(Color(0.7, 0.68, 0.65), "stone")
	Builder.box(self, Vector3(-3.5, h + 1.0, cz - 3.5), Vector3(0.8, 2.0, 0.8), chim)

func _build_houses() -> void:
	for bx: float in BLOCK_POSITIONS:
		for bz: float in BLOCK_POSITIONS:
			if absf(bx) <= 12.0 and absf(bz) <= 12.0:
				continue
			if _rng.randf() < 0.3:
				continue
			var px: float = bx + _rng.randf_range(-1.0, 1.0)
			var pz: float = bz + _rng.randf_range(-1.0, 1.0)
			_build_house(px, pz)

func _build_house(cx: float, cz: float) -> void:
	var w := _rng.randf_range(9.0, 13.0)
	var d := _rng.randf_range(9.0, 13.0)
	var ruined := _rng.randf() < 0.55
	var h: float = _rng.randf_range(2.6, 4.2) if ruined else _rng.randf_range(4.5, 7.5)
	var r := _rng.randf()
	var tex_name := "stone" if r < 0.5 else ("brick" if r < 0.8 else "concrete")
	var wall := _mat(Color(0.85, 0.84, 0.82), tex_name)
	var hw := w / 2.0
	var hd := d / 2.0
	_make_wall(cx, cz - hd, Vector3(w, h, 0.5), wall, true)
	_make_wall(cx, cz + hd, Vector3(w, h, 0.5), wall, true)
	_make_wall(cx - hw, cz, Vector3(0.5, h, d), wall, false)
	_make_wall(cx + hw, cz, Vector3(0.5, h, d), wall, false)
	if _rng.randf() < 0.7:
		var chim := _mat(Color(0.7, 0.68, 0.65), "stone")
		var chim_pos := Vector3(cx + hw - 1.0, h + 0.9, cz - hd + 1.0)
		Builder.box(self, chim_pos, Vector3(0.8, 1.8, 0.8), chim)
	var roof := _mat(Color(0.6, 0.58, 0.55), "roof")
	if not ruined or _rng.randf() < 0.5:
		var tilt := _rng.randf_range(-0.25, 0.25) if ruined else _rng.randf_range(-0.06, 0.06)
		var roof_pos := Vector3(cx + _rng.randf_range(-0.5, 0.5), h + 0.15, cz)
		Builder.box(self, roof_pos, Vector3(w + 0.6, 0.25, d + 0.6), roof, Vector3(0, 0, tilt))
	else:
		var fallen := Vector3(cx + w * 0.2, 0.15, cz + d * 0.3)
		var fallen_rot := Vector3(0, 0, _rng.randf_range(0.3, 0.8))
		Builder.box(self, fallen, Vector3(w * 0.7, 0.3, d * 0.5), roof, fallen_rot)
	if _rng.randf() < 0.25:
		var light := OmniLight3D.new()
		light.light_color = WARM
		light.light_energy = 0.7
		light.omni_range = 8.0
		light.shadow_enabled = false
		light.position = Vector3(cx, h * 0.6, cz)
		add_child(light)

func _make_wall(cx: float, cz: float, size: Vector3, mat: Material, horizontal: bool) -> void:
	var gap := _rng.randf_range(1.2, 2.0)
	var len := size.x if horizontal else size.z
	var seg := (len - gap) / 2.0
	var off := gap / 2.0 + seg / 2.0
	for side in [-1.0, 1.0]:
		var pos := Vector3(cx, size.y / 2.0, cz)
		if horizontal:
			pos.x = cx + side * off
			Builder.box(self, pos, Vector3(seg, size.y, size.z), mat)
		else:
			pos.z = cz + side * off
			Builder.box(self, pos, Vector3(size.x, size.y, seg), mat)

func _build_lamps() -> void:
	var spots := [
		Vector2(20, 20), Vector2(-20, 20), Vector2(20, -20), Vector2(-20, -20),
		Vector2(40, 0), Vector2(-40, 0), Vector2(0, 40), Vector2(0, -40),
		Vector2(40, 40), Vector2(-40, -40), Vector2(40, -40), Vector2(-40, 40),
	]
	for i in range(spots.size()):
		var s: Vector2 = spots[i]
		_box(Vector3(s.x, 2.25, s.y), Vector3(0.18, 4.5, 0.18), Color(0.5, 0.52, 0.56), "metal")
		var head := _box(Vector3(s.x, 4.6, s.y), Vector3(0.55, 0.3, 0.55), NEON, "", true)
		var light := OmniLight3D.new()
		light.light_color = NEON
		light.light_energy = 0.45
		light.omni_range = 7.0
		light.shadow_enabled = false
		head.add_child(light)
		_lamp_lights.append({"light": light, "phase": i * 1.7, "base": 0.45})

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

func _build_props() -> void:
	for i in range(18):
		var pos := _street_pos()
		if pos == Vector3.ZERO:
			continue
		match i % 6:
			0:
				_cyl(pos + Vector3(0, 0.45, 0), 0.4, 0.9, Color(0.55, 0.42, 0.3), "wood")
			1:
				var rot := Vector3(0, _rng.randf_range(0, 3), 0)
				var crate_pos := pos + Vector3(0, 0.4, 0)
				_box(crate_pos, Vector3(0.8, 0.8, 0.8), Color(0.75, 0.62, 0.45), "wood", false, rot)
			2:
				_make_fence(pos)
			3:
				_make_cart(pos)
			4:
				var hay_rot := Vector3(0, 0, _rng.randf_range(-0.3, 0.3))
				var hay_pos := pos + Vector3(0, 0.3, 0)
				var hay_tint := Color(0.55, 0.55, 0.45)
				_box(hay_pos, Vector3(1.4, 0.6, 1.0), hay_tint, "concrete", false, hay_rot)
			5:
				_make_scattered(pos)

func _make_fence(pos: Vector3) -> void:
	var wood := Color(0.6, 0.5, 0.38)
	for j in range(3):
		var p := pos + Vector3(j * 0.9 - 0.9, 0.6, 0)
		var rot := Vector3(0, _rng.randf_range(-0.2, 0.2), 0.1)
		_box(p, Vector3(0.08, 1.2, 0.08), wood, "wood", false, rot)
	_box(pos + Vector3(-0.9, 0.9, 0), Vector3(2.0, 0.08, 0.08), wood, "wood")

func _make_cart(pos: Vector3) -> void:
	var body_rot := Vector3(0, 0.3, 0.15)
	var cart_pos := pos + Vector3(0, 0.5, 0)
	_box(cart_pos, Vector3(1.8, 0.5, 0.9), Color(0.6, 0.48, 0.35), "wood", false, body_rot)
	var wheel_rot := Vector3(PI / 2.0, 0, 0)
	_cyl(pos + Vector3(-0.7, 0.35, 0.55), 0.35, 0.08, Color(0.4, 0.4, 0.42), "metal", wheel_rot)
	_cyl(pos + Vector3(0.7, 0.35, 0.55), 0.35, 0.08, Color(0.4, 0.4, 0.42), "metal", wheel_rot)

func _make_scattered(pos: Vector3) -> void:
	var plank_rot := Vector3(0, 0, _rng.randf_range(-0.5, 0.5))
	var plank_pos := pos + Vector3(0, 0.06, 0)
	_box(plank_pos, Vector3(1.6, 0.08, 0.3), Color(0.65, 0.52, 0.38), "wood", false, plank_rot)
	_box(pos + Vector3(0.5, 0.1, 0.3), Vector3(0.25, 0.06, 0.18), Color(0.85, 0.82, 0.72))

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

func _register_debris(node: StaticBody3D) -> void:
	var dir := (SkyManager.PLANET_AI_POSITION - node.position).normalized()
	_debris.append({"node": node, "base": node.position, "dir": dir})

func _process(_delta: float) -> void:
	var p := LoopManager.progress()
	for d in _debris:
		var node: StaticBody3D = d["node"]
		var base: Vector3 = d["base"]
		var dir: Vector3 = d["dir"]
		node.position = base + dir * (p * 6.0) + Vector3(0, p * 2.0, 0)
	var t := Time.get_ticks_msec() / 1000.0
	for entry in _lamp_lights:
		var light: OmniLight3D = entry["light"]
		light.light_energy = entry["base"] * (0.8 + 0.2 * sin(t * 9.0 + entry["phase"]))

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
		var size := Vector3(s, s * _rng.randf_range(0.5, 1.0), s)
		_register_debris(_box(pos, size, tint, "concrete", false, tilt))

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
		var size := Vector3(s, s * 0.6, s)
		_register_debris(_box(Vector3(x, y, z), size, tint, "concrete", false, tilt))

func _build_pickups() -> void:
	_make_relic("radio", Vector3(12.0, 0.0, -18.0))
	_make_relic("livre", Vector3(-14.0, 0.0, 8.0))
	_make_relic("conserve", Vector3(20.0, 0.0, 30.0))
	_make_relic("conserve", Vector3(-30.0, 0.0, -20.0))

func _make_relic(kind: String, pos: Vector3) -> void:
	var relic := Relic.new()
	relic.kind = kind
	relic.position = pos
	add_child(relic)
