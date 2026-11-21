extends Node3D

const Builder := preload("res://scripts/builder.gd")
const Tex := preload("res://scripts/textures.gd")
const SkyManager := preload("res://scripts/sky_manager.gd")
const Relic := preload("res://scripts/relic.gd")
const Note := preload("res://scripts/note.gd")

const CITY_HALF := 58.0
const SHAFT_MIN := Vector2(-2.0, 2.0)
const SHAFT_MAX := Vector2(2.0, 8.0)
const BLOCK_POSITIONS := [10.0, 30.0, 50.0, -10.0, -30.0, -50.0]
const FORCED_TYPES := {
	Vector2(30, 30): "shop_boulangerie",
	Vector2(-30, -30): "shop_echoppe",
	Vector2(30, -30): "library",
	Vector2(-30, 30): "apartment",
}
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
		"stone_dark": Tex.make_stone_dark(),
		"brick": Tex.make_brick(),
		"brick_brown": Tex.make_brick_brown(),
		"concrete": Tex.make_concrete(),
		"dirt": Tex.make_dirt(),
		"plaster": Tex.make_plaster(),
		"wood": Tex.make_wood(),
		"metal": Tex.make_metal(),
		"roof": Tex.make_roof(),
	}
	_build_ground()
	_build_ground_details()
	_build_auberge()
	_build_houses()
	_build_signs()
	_build_lamps()
	_build_pillars()
	_build_doors()
	_build_props()
	_build_rubble()
	_build_border()

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

func _make_note(pos: Vector3, file: String) -> void:
	var note := Note.new()
	note.note_file = file
	note.position = pos
	add_child(note)

func _make_relic(kind: String, pos: Vector3) -> void:
	var relic := Relic.new()
	relic.kind = kind
	relic.position = pos
	add_child(relic)

func _make_sign(pos: Vector3, text: String) -> void:
	var post_tint := Color(0.4, 0.32, 0.22)
	_box(pos + Vector3(0, 1.1, 0), Vector3(0.16, 2.2, 0.16), post_tint, "wood")
	_box(pos + Vector3(0, 2.05, 0), Vector3(1.9, 0.55, 0.1), Color(0.55, 0.45, 0.32), "wood")
	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.position = pos + Vector3(0, 2.05, 0.06)
	label.pixel_size = 0.008
	label.modulate = Color(0.95, 0.9, 0.75)
	label.outline_size = 6
	label.outline_modulate = Color(0, 0, 0, 0.9)
	add_child(label)

func _build_ground() -> void:
	var t := Color(0.9, 0.88, 0.85)
	Builder.box(self, Vector3(0, -0.5, -28.0), Vector3(116.0, 1.0, 60.0), _mat(t, "dirt"))
	Builder.box(self, Vector3(0, -0.5, 33.0), Vector3(116.0, 1.0, 50.0), _mat(t, "dirt"))
	Builder.box(self, Vector3(-30.0, -0.5, 5.0), Vector3(56.0, 1.0, 6.0), _mat(t, "dirt"))
	Builder.box(self, Vector3(30.0, -0.5, 5.0), Vector3(56.0, 1.0, 6.0), _mat(t, "dirt"))

func _build_auberge() -> void:
	var cz := -6.0
	var h := 3.5
	var wall := _mat(Color(0.85, 0.82, 0.78), "brick")
	Builder.box(self, Vector3(0, h / 2.0, cz - 5.0), Vector3(10.0, h, 0.6), wall)
	Builder.box(self, Vector3(-3.0, h / 2.0, cz + 5.0), Vector3(4.0, h, 0.6), wall)
	Builder.box(self, Vector3(3.0, h / 2.0, cz + 5.0), Vector3(4.0, h, 0.6), wall)
	Builder.box(self, Vector3(-5.0, h / 2.0, cz), Vector3(0.6, h, 10.0), wall)
	Builder.box(self, Vector3(5.0, h / 2.0, cz), Vector3(0.6, h, 10.0), wall)
	var found := _mat(Color(0.42, 0.42, 0.44), "concrete")
	Builder.box(self, Vector3(0, 0.2, cz), Vector3(10.5, 0.4, 10.5), found)
	var slab_mat := _mat(Color(0.55, 0.52, 0.48), "roof")
	var slab_pos := Vector3(0.4, h + 0.12, cz - 0.6)
	Builder.box(self, slab_pos, Vector3(10.5, 0.3, 10.5), slab_mat, Vector3(0, 0, 0.08))
	var chim := _mat(Color(0.7, 0.68, 0.65), "stone")
	Builder.box(self, Vector3(-3.5, h + 1.0, cz - 3.5), Vector3(0.8, 2.0, 0.8), chim)
	_make_sign(Vector3(0, 0, cz + 6.5), "Auberge")

func _build_houses() -> void:
	for bx: float in BLOCK_POSITIONS:
		for bz: float in BLOCK_POSITIONS:
			if absf(bx) <= 12.0 and absf(bz) <= 12.0:
				continue
			var cell := Vector2(bx, bz)
			var forced: String = FORCED_TYPES.get(cell, "")
			if forced == "" and _rng.randf() < 0.3:
				continue
			var px: float = bx + _rng.randf_range(-1.0, 1.0)
			var pz: float = bz + _rng.randf_range(-1.0, 1.0)
			if forced == "shop_boulangerie":
				_build_shop(px, pz, "Boulangerie", "res://data/notes/journal_boulanger.json")
			elif forced == "shop_echoppe":
				_build_shop(px, pz, "Échoppe", "")
			elif forced == "library":
				_build_library(px, pz)
			elif forced == "apartment":
				_build_apartment(px, pz, true)
			else:
				var r := _rng.randf()
				if r < 0.6:
					_build_house(px, pz)
				elif r < 0.8:
					_build_shop(px, pz, "", "")
				else:
					_build_apartment(px, pz)

func _make_wall(
	cx: float, cz: float, size: Vector3, mat: Material, horizontal: bool, with_door := false
) -> void:
	var gap := 2.0 if with_door else _rng.randf_range(1.2, 2.0)
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
	if with_door:
		var jamb := _mat(Color(0.5, 0.5, 0.52), "concrete")
		for side in [-1.0, 1.0]:
			var jp := Vector3(cx + side * gap / 2.0, size.y / 2.0, cz)
			if horizontal:
				Builder.box(self, jp, Vector3(0.2, size.y, size.z + 0.15), jamb)
			else:
				Builder.box(self, jp, Vector3(size.x + 0.15, size.y, 0.2), jamb)
		var lintel := Vector3(cx, size.y - 0.15, cz)
		var lsize := Vector3.ZERO
		if horizontal:
			lsize = Vector3(gap + 0.4, 0.3, size.z + 0.15)
		else:
			lsize = Vector3(size.x + 0.15, 0.3, gap + 0.4)
		Builder.box(self, lintel, lsize, jamb)
	elif len > 7.0 and _rng.randf() < 0.8:
		_make_window(cx, cz, horizontal)

func _make_window(cx: float, cz: float, horizontal: bool) -> void:
	var off := _rng.randf_range(-3.0, 3.0)
	var frame := _mat(Color(0.55, 0.54, 0.52), "stone")
	var dark := _mat(Color(0.09, 0.11, 0.13))
	if horizontal:
		var fp := Vector3(cx + off, 2.0, cz + 0.28)
		var gp := Vector3(cx + off, 2.0, cz + 0.33)
		Builder.box(self, fp, Vector3(0.9, 1.2, 0.08), frame)
		Builder.box(self, gp, Vector3(0.7, 1.0, 0.04), dark)
	else:
		var fp := Vector3(cx + 0.28, 2.0, cz + off)
		var gp := Vector3(cx + 0.33, 2.0, cz + off)
		Builder.box(self, fp, Vector3(0.08, 1.2, 0.9), frame)
		Builder.box(self, gp, Vector3(0.04, 1.0, 0.7), dark)

func _build_house(cx: float, cz: float) -> void:
	var w := _rng.randf_range(8.0, 13.0)
	var d := _rng.randf_range(8.0, 13.0)
	var ruined := _rng.randf() < 0.55
	var h: float = _rng.randf_range(2.6, 4.2) if ruined else _rng.randf_range(4.5, 7.0)
	var texes := ["stone", "stone_dark", "brick", "brick_brown", "plaster", "concrete"]
	var tex_name: String = texes[_rng.randi_range(0, texes.size() - 1)]
	var tints := [
		Color(0.85, 0.84, 0.82), Color(0.8, 0.77, 0.7),
		Color(0.76, 0.82, 0.76), Color(0.88, 0.86, 0.78),
	]
	var tint: Color = tints[_rng.randi_range(0, tints.size() - 1)] * _rng.randf_range(0.92, 1.08)
	var wall := _mat(tint, tex_name)
	var hw := w / 2.0
	var hd := d / 2.0
	_make_wall(cx, cz - hd, Vector3(w, h, 0.5), wall, true)
	_make_wall(cx, cz + hd, Vector3(w, h, 0.5), wall, true, true)
	_make_wall(cx - hw, cz, Vector3(0.5, h, d), wall, false)
	_make_wall(cx + hw, cz, Vector3(0.5, h, d), wall, false)
	var found := _mat(Color(0.42, 0.42, 0.44), "concrete")
	Builder.box(self, Vector3(cx, 0.2, cz), Vector3(w + 0.5, 0.4, d + 0.5), found)
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
		var fallen_rot := Vector3(0, 0, _rng.randf_range(0.3, 0.8))
		var fallen := Vector3(cx + w * 0.2, 0.15, cz + d * 0.3)
		Builder.box(self, fallen, Vector3(w * 0.7, 0.3, d * 0.5), roof, fallen_rot)
	if not ruined and _rng.randf() < 0.4:
		var wood := _mat(Color(0.6, 0.48, 0.35), "wood")
		var table_pos := Vector3(cx + 1.0, 0.4, cz + 1.0)
		Builder.box(self, table_pos, Vector3(1.2, 0.8, 0.8), wood)
	if _rng.randf() < 0.25:
		var light := OmniLight3D.new()
		light.light_color = WARM
		light.light_energy = 0.7
		light.omni_range = 8.0
		light.shadow_enabled = false
		light.position = Vector3(cx, h * 0.6, cz)
		add_child(light)

func _build_shop(cx: float, cz: float, name: String, note_file: String) -> void:
	var w := _rng.randf_range(9.0, 12.0)
	var d := _rng.randf_range(9.0, 12.0)
	var h := 4.5
	var wall := _mat(Color(0.85, 0.82, 0.78), "brick")
	var hw := w / 2.0
	var hd := d / 2.0
	_make_wall(cx, cz - hd, Vector3(w, h, 0.5), wall, true)
	_make_wall(cx, cz + hd, Vector3(w, h, 0.5), wall, true, true)
	_make_wall(cx - hw, cz, Vector3(0.5, h, d), wall, false)
	_make_wall(cx + hw, cz, Vector3(0.5, h, d), wall, false)
	var found := _mat(Color(0.42, 0.42, 0.44), "concrete")
	Builder.box(self, Vector3(cx, 0.2, cz), Vector3(w + 0.5, 0.4, d + 0.5), found)
	var roof := _mat(Color(0.6, 0.58, 0.55), "roof")
	Builder.box(self, Vector3(cx, h + 0.15, cz), Vector3(w + 0.6, 0.25, d + 0.6), roof)
	var awning := _mat(Color(0.55, 0.5, 0.45), "wood")
	var awn_pos := Vector3(cx, 3.0, cz + hd + 0.7)
	Builder.box(self, awn_pos, Vector3(3.5, 0.08, 1.2), awning, Vector3(-0.25, 0, 0))
	var wood := _mat(Color(0.6, 0.48, 0.35), "wood")
	var counter := Vector3(cx, 0.5, cz - hd + 0.9)
	Builder.box(self, counter, Vector3(w - 2.0, 1.0, 0.6), wood)
	_shelf_x(cx, cz - hd + 0.45, w - 1.5, 2.4)
	_shelf_z(cx + hw - 0.45, cz, d - 1.5, 2.4)
	if name != "":
		_make_sign(Vector3(cx, 0, cz + hd + 1.8), name)
	if note_file != "":
		_make_note(Vector3(cx + 0.8, 1.012, cz - hd + 0.9), note_file)
	_add_warm_light(cx, cz, h * 0.5)

func _build_library(cx: float, cz: float) -> void:
	var w := 12.0
	var d := 12.0
	var h := 7.0
	var wall := _mat(Color(0.85, 0.84, 0.82), "stone")
	var hw := w / 2.0
	var hd := d / 2.0
	_make_wall(cx, cz - hd, Vector3(w, h, 0.5), wall, true)
	_make_wall(cx, cz + hd, Vector3(w, h, 0.5), wall, true, true)
	_make_wall(cx - hw, cz, Vector3(0.5, h, d), wall, false)
	_make_wall(cx + hw, cz, Vector3(0.5, h, d), wall, false)
	var found := _mat(Color(0.42, 0.42, 0.44), "concrete")
	Builder.box(self, Vector3(cx, 0.2, cz), Vector3(w + 0.5, 0.4, d + 0.5), found)
	var roof := _mat(Color(0.55, 0.53, 0.5), "roof")
	Builder.box(self, Vector3(cx, h + 0.15, cz), Vector3(w + 0.6, 0.25, d + 0.6), roof)
	_shelf_x(cx, cz - hd + 0.5, w - 1.2, 2.6)
	_shelf_x(cx, cz + hd - 0.5, w - 1.2, 2.6)
	_shelf_z(cx - hw + 0.5, cz, d - 1.2, 2.6)
	_shelf_z(cx + hw - 0.5, cz, d - 1.2, 2.6)
	_shelf_x(cx, cz, w - 4.0, 2.2)
	_make_sign(Vector3(cx, 0, cz + hd + 1.8), "Bibliothèque")
	_make_note(Vector3(cx, 1.137, cz), "res://data/notes/inventaire_biblio.json")
	_make_note(Vector3(cx + hw - 0.5, 1.336, cz - 1.0), "res://data/notes/note_mnemo.json")
	_make_relic("livre", Vector3(cx - hw + 0.5, 1.48, cz + 1.5))
	_add_warm_light(cx, cz, h * 0.5)

func _build_apartment(cx: float, cz: float, with_story := false) -> void:
	var w := 10.0
	var d := 12.0
	var h := 7.5
	var wall := _mat(Color(0.82, 0.8, 0.74), "plaster")
	var hw := w / 2.0
	var hd := d / 2.0
	_make_wall(cx, cz - hd, Vector3(w, h, 0.5), wall, true)
	_make_wall(cx, cz + hd, Vector3(w, h, 0.5), wall, true, true)
	_make_wall(cx - hw, cz, Vector3(0.5, h, d), wall, false)
	_make_wall(cx + hw, cz, Vector3(0.5, h, d), wall, false)
	var found := _mat(Color(0.42, 0.42, 0.44), "concrete")
	Builder.box(self, Vector3(cx, 0.2, cz), Vector3(w + 0.5, 0.4, d + 0.5), found)
	var roof := _mat(Color(0.58, 0.56, 0.53), "roof")
	Builder.box(self, Vector3(cx, h + 0.15, cz), Vector3(w + 0.6, 0.25, d + 0.6), roof)
	var bed := _mat(Color(0.55, 0.5, 0.45), "concrete")
	var pillow := _mat(Color(0.8, 0.78, 0.72), "plaster")
	Builder.box(self, Vector3(cx - hw + 1.2, 0.2, cz), Vector3(0.9, 0.4, 2.2), bed)
	Builder.box(self, Vector3(cx - hw + 0.9, 0.45, cz - 0.8), Vector3(0.5, 0.12, 0.6), pillow)
	var wood := _mat(Color(0.6, 0.48, 0.35), "wood")
	var table_top := Vector3(cx + 1.5, 0.75, cz + 1.0)
	Builder.box(self, table_top, Vector3(1.2, 0.08, 0.8), wood)
	for dx in [-0.5, 0.5]:
		for dz in [-0.3, 0.3]:
			var leg := Vector3(cx + 1.5 + dx, 0.37, cz + 1.0 + dz)
			Builder.box(self, leg, Vector3(0.08, 0.75, 0.08), wood)
	var desk := Vector3(cx, 0.4, cz - hd + 0.7)
	Builder.box(self, desk, Vector3(1.2, 0.8, 0.6), wood)
	if with_story:
		_make_note(Vector3(cx - 0.3, 0.812, cz - hd + 0.7), "res://data/notes/lettre_lea.json")
	_shelf_z(cx + hw - 0.5, cz, d - 2.0, 2.2)
	_make_relic("conserve", Vector3(cx + hw - 0.5, 1.48, cz - 2.0))
	_add_poster(cx - 1.5, 2.2, cz - hd + 0.3, Color(0.6, 0.55, 0.45))
	_add_poster(cx + 1.5, 2.4, cz - hd + 0.3, Color(0.55, 0.5, 0.56))
	_add_warm_light(cx, cz, h * 0.5)

func _shelf_x(cx: float, cz: float, length: float, h: float) -> void:
	var wood := _mat(Color(0.6, 0.48, 0.35), "wood")
	Builder.box(self, Vector3(cx, h / 2.0, cz), Vector3(length, h, 0.35), wood)
	for i in range(1, 4):
		var y := i * h / 4.0
		Builder.box(self, Vector3(cx, y, cz + 0.16), Vector3(length, 0.05, 0.4), wood)

func _shelf_z(cx: float, cz: float, length: float, h: float) -> void:
	var wood := _mat(Color(0.6, 0.48, 0.35), "wood")
	Builder.box(self, Vector3(cx, h / 2.0, cz), Vector3(0.35, h, length), wood)
	for i in range(1, 4):
		var y := i * h / 4.0
		Builder.box(self, Vector3(cx + 0.16, y, cz), Vector3(0.4, 0.05, length), wood)

func _build_signs() -> void:
	_make_sign(Vector3(3.5, 0, 12), "Cendreval")
	_make_note(Vector3(4.5, 0.012, -2), "res://data/notes/affiche_eglise.json")
	_make_note(Vector3(-3, 0.012, 0.5), "res://data/notes/note_enfant.json")
	_make_note(Vector3(1.5, 0.012, -3), "res://data/notes/note_glaneur.json")
	_box(Vector3(-21.5, 0.4, 0), Vector3(0.8, 0.8, 0.8), Color(0.7, 0.58, 0.42), "wood")
	_make_note(Vector3(-21.5, 0.812, 0), "res://data/notes/note_amarreur.json")

func _add_warm_light(cx: float, cz: float, y: float) -> void:
	var light := OmniLight3D.new()
	light.light_color = WARM
	light.light_energy = 0.6
	light.omni_range = 9.0
	light.shadow_enabled = false
	light.position = Vector3(cx, y, cz)
	add_child(light)

func _add_poster(cx: float, y: float, cz: float, tint: Color) -> void:
	_box(Vector3(cx, y, cz), Vector3(0.5, 0.7, 0.05), tint)

func _build_ground_details() -> void:
	for i in range(40):
		var x := _rng.randf_range(-55.0, 55.0)
		var z := _rng.randf_range(-55.0, 55.0)
		if _in_shaft(x, z, 1.0):
			continue
		var s := _rng.randf_range(0.08, 0.22)
		_box(Vector3(x, s / 2.0, z), Vector3(s, s, s), Color(0.42, 0.42, 0.44), "concrete")
	for i in range(25):
		var x := _rng.randf_range(-55.0, 55.0)
		var z := _rng.randf_range(-55.0, 55.0)
		if _in_shaft(x, z, 1.0):
			continue
		var g := _rng.randf_range(0.15, 0.3)
		var tint := Color(0.4, 0.5, 0.32) * _rng.randf_range(0.9, 1.1)
		_box(Vector3(x, g / 2.0, z), Vector3(0.12, g, 0.12), tint)

func _build_lamps() -> void:
	var spots := [
		Vector2(20, 20), Vector2(-20, 20), Vector2(20, -20), Vector2(-20, -20),
		Vector2(40, 0), Vector2(-40, 0), Vector2(0, 40), Vector2(0, -40),
		Vector2(40, 40), Vector2(-40, -40), Vector2(40, -40), Vector2(-40, 40),
	]
	var metal := Color(0.3, 0.31, 0.34)
	var base_tint := Color(0.32, 0.33, 0.36)
	for i in range(spots.size()):
		var spot: Vector2 = spots[i]
		var x := spot.x
		var z := spot.y
		_box(Vector3(x, 0.15, z), Vector3(0.5, 0.3, 0.5), base_tint, "concrete")
		_box(Vector3(x, 2.25, z), Vector3(0.14, 4.2, 0.14), metal, "metal")
		_box(Vector3(x + 0.4, 4.5, z), Vector3(0.9, 0.1, 0.1), metal, "metal")
		var lx := x + 0.8
		_box(Vector3(lx, 4.55, z), Vector3(0.36, 0.42, 0.36), metal, "metal")
		_box(Vector3(lx, 4.55, z), Vector3(0.26, 0.3, 0.26), NEON, "", true)
		_box(Vector3(lx, 4.82, z), Vector3(0.42, 0.08, 0.42), metal, "metal")
		var light := OmniLight3D.new()
		light.light_color = NEON
		light.light_energy = 0.5
		light.omni_range = 8.0
		light.shadow_enabled = false
		light.position = Vector3(lx, 4.4, z)
		add_child(light)
		_lamp_lights.append({"light": light, "phase": i * 1.7, "base": 0.5})

func _build_pillars() -> void:
	var spots := [
		Vector2(0, -20), Vector2(0, 20), Vector2(-20, 0),
		Vector2(20, 0), Vector2(-40, 0), Vector2(40, 0),
	]
	for s: Vector2 in spots:
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
		match i % 7:
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
			6:
				_make_car_wreck(pos)

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
	var wheel_tint := Color(0.4, 0.4, 0.42)
	_cyl(pos + Vector3(-0.7, 0.35, 0.55), 0.35, 0.08, wheel_tint, "metal", wheel_rot)
	_cyl(pos + Vector3(0.7, 0.35, 0.55), 0.35, 0.08, wheel_tint, "metal", wheel_rot)

func _make_car_wreck(pos: Vector3) -> void:
	var tint := Color(0.38, 0.39, 0.42) * _rng.randf_range(0.85, 1.1)
	var rot := Vector3(
		_rng.randf_range(-0.1, 0.1), _rng.randf_range(0, 3), _rng.randf_range(-0.15, 0.15)
	)
	var body_pos := pos + Vector3(0, 0.55, 0)
	_box(body_pos, Vector3(2.4, 0.8, 1.2), tint, "metal", false, rot)
	var cabin_pos := pos + Vector3(0, 1.05, 0)
	_box(cabin_pos, Vector3(1.4, 0.5, 1.1), Color(0.18, 0.2, 0.22), "", false, rot)
	var wheel_rot := Vector3(PI / 2.0, 0, 0)
	var wheel_tint := Color(0.14, 0.14, 0.15)
	for dx in [-0.8, 0.8]:
		for dz in [-0.6, 0.6]:
			var wp := pos + Vector3(dx, 0.3, dz)
			_cyl(wp, 0.3, 0.1, wheel_tint, "", wheel_rot)

func _make_scattered(pos: Vector3) -> void:
	var plank_rot := Vector3(0, 0, _rng.randf_range(-0.5, 0.5))
	var plank_pos := pos + Vector3(0, 0.06, 0)
	_box(plank_pos, Vector3(1.6, 0.08, 0.3), Color(0.65, 0.52, 0.38), "wood", false, plank_rot)
	_box(pos + Vector3(0.5, 0.1, 0.3), Vector3(0.25, 0.06, 0.18), Color(0.85, 0.82, 0.72))

func _build_rubble() -> void:
	for i in range(12):
		var cx := _rng.randf_range(-52.0, 52.0)
		var cz := _rng.randf_range(-52.0, 52.0)
		if _in_shaft(cx, cz, 2.0):
			continue
		var n := _rng.randi_range(3, 6)
		for j in range(n):
			var s := _rng.randf_range(0.3, 1.1)
			var dx := _rng.randf_range(-1.5, 1.5)
			var dz := _rng.randf_range(-1.5, 1.5)
			var sink := _rng.randf_range(-0.15, 0.05)
			var tilt := Vector3(
				_rng.randf_range(-0.5, 0.5), _rng.randf_range(0, 3), _rng.randf_range(-0.5, 0.5)
			)
			var tint := Color(0.5, 0.5, 0.52) * _rng.randf_range(0.85, 1.1)
			var size := Vector3(s, s * _rng.randf_range(0.5, 0.9), s * _rng.randf_range(0.6, 1.0))
			_box(Vector3(cx + dx, s / 2.0 + sink, cz + dz), size, tint, "concrete", false, tilt)

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
		var tint := Color(0.55, 0.53, 0.5)
		var tilt := Vector3(0, 0, _rng.randf_range(-0.4, 0.4))
		var size := Vector3(s, s * _rng.randf_range(0.5, 1.0), s)
		_register_debris(_box(pos, size, tint, "stone", false, tilt))


