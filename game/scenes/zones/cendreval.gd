extends Node3D

const CITY_HALF := 58.0
const BLOCK_POSITIONS := [10.0, 30.0, 50.0, -10.0, -30.0, -50.0]
const PALETTE := [
	Color(0.40, 0.40, 0.43),
	Color(0.48, 0.47, 0.45),
	Color(0.58, 0.57, 0.53),
	Color(0.34, 0.36, 0.34),
	Color(0.52, 0.50, 0.44),
]
const RED := Color(0.62, 0.10, 0.07)
const GROUND := Color(0.23, 0.23, 0.26)
const RUBBLE := Color(0.30, 0.30, 0.32)

var _rng := RandomNumberGenerator.new()
var _materials := {}

func _ready() -> void:
	_rng.seed = 2200
	_build_ground()
	_build_auberge()
	_build_blocks()
	_build_border()
	_build_debris()

func _mat(color: Color, emission := false) -> StandardMaterial3D:
	var key := color.to_html() + ("|e" if emission else "")
	if not _materials.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = color
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		if emission:
			m.emission_enabled = true
			m.emission = color
			m.emission_energy_multiplier = 1.5
		_materials[key] = m
	return _materials[key]

func _box(pos: Vector3, size: Vector3, color: Color, emission := false, tilt := 0.0) -> CSGBox3D:
	var b := CSGBox3D.new()
	b.size = size
	b.position = pos
	b.material = _mat(color, emission)
	if tilt != 0.0:
		b.rotation.z = tilt
	add_child(b)
	return b

func _build_ground() -> void:
	_box(Vector3(0, -0.5, 0), Vector3(CITY_HALF * 2.0, 1.0, CITY_HALF * 2.0), GROUND)

func _build_auberge() -> void:
	var h := 3.5
	var color: Color = PALETTE[1]
	_box(Vector3(0, h / 2.0, -5.0), Vector3(10.0, h, 0.6), color)
	_box(Vector3(0, h / 2.0, 5.0), Vector3(10.0, h, 0.6), color)
	_box(Vector3(-5.0, h / 2.0, 0), Vector3(0.6, h, 10.0), color)
	_box(Vector3(5.0, h / 2.0, 0), Vector3(0.6, h, 10.0), color)
	_box(Vector3(0.4, 7.0, -0.6), Vector3(10.0, 0.4, 10.0), PALETTE[0], false, 0.22)

func _build_blocks() -> void:
	for bx in BLOCK_POSITIONS:
		for bz in BLOCK_POSITIONS:
			if absf(bx) <= 12.0 and absf(bz) <= 12.0:
				continue
			if _rng.randf() < 0.25:
				continue
			var w := _rng.randf_range(8.0, 12.0)
			var d := _rng.randf_range(8.0, 12.0)
			var h := _rng.randf_range(5.0, 13.0)
			var px := bx + _rng.randf_range(-1.0, 1.0)
			var pz := bz + _rng.randf_range(-1.0, 1.0)
			var color: Color = PALETTE[_rng.randi_range(0, PALETTE.size() - 1)]
			var ruined := _rng.randf() < 0.4
			if ruined:
				h *= 0.45
			var tilt := 0.0
			if ruined:
				tilt = _rng.randf_range(-0.1, 0.1)
			_box(Vector3(px, h / 2.0, pz), Vector3(w, h, d), color, false, tilt)
			if ruined:
				var slab_pos := Vector3(px + w * 0.4, h + 1.2, pz - d * 0.3)
				var slab_tilt := _rng.randf_range(-0.3, 0.3)
				_box(slab_pos, Vector3(w * 0.6, 0.4, d * 0.6), PALETTE[0], false, slab_tilt)

func _build_border() -> void:
	var len := CITY_HALF * 2.0
	_box(Vector3(0, 0.15, -CITY_HALF), Vector3(len, 0.3, 0.4), RED, true)
	_box(Vector3(0, 0.15, CITY_HALF), Vector3(len, 0.3, 0.4), RED, true)
	_box(Vector3(-CITY_HALF, 0.15, 0), Vector3(0.4, 0.3, len), RED, true)
	_box(Vector3(CITY_HALF, 0.15, 0), Vector3(0.4, 0.3, len), RED, true)
	for i in range(14):
		var side := _rng.randi_range(0, 3)
		var along := _rng.randf_range(-CITY_HALF, CITY_HALF)
		var y := _rng.randf_range(10.0, 48.0)
		var pos := Vector3.ZERO
		var out := _rng.randf_range(2.0, 14.0)
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
		var chunk_color: Color = PALETTE[_rng.randi_range(0, PALETTE.size() - 1)]
		var chunk_tilt := _rng.randf_range(-0.4, 0.4)
		_box(pos, Vector3(s, s * _rng.randf_range(0.5, 1.0), s), chunk_color, false, chunk_tilt)

func _build_debris() -> void:
	for i in range(30):
		var s := _rng.randf_range(0.4, 1.6)
		var dx := _rng.randf_range(-CITY_HALF + 2.0, CITY_HALF - 2.0)
		var dz := _rng.randf_range(-CITY_HALF + 2.0, CITY_HALF - 2.0)
		_box(Vector3(dx, s / 2.0, dz), Vector3(s, s, s), RUBBLE, false, _rng.randf_range(-0.5, 0.5))
