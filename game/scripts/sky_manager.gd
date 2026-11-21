extends Node

const SKY_TOP_START := Color(0.52, 0.56, 0.62)
const SKY_TOP_END := Color(0.14, 0.07, 0.09)
const SKY_HOR_START := Color(0.66, 0.68, 0.70)
const SKY_HOR_END := Color(0.45, 0.15, 0.10)
const FOG_START := Color(0.66, 0.68, 0.70)
const FOG_END := Color(0.42, 0.16, 0.11)
const FOG_DENSITY_START := 0.045
const FOG_DENSITY_END := 0.08
const MARS_POSITION := Vector3(-260.0, 190.0, -620.0)
const PLANET_AI_POSITION := Vector3(420.0, 80.0, -720.0)
const MARS_SCALE_START := 0.5
const MARS_SCALE_END := 16.0
const PLANET_AI_SCALE_START := 4.0
const PLANET_AI_SCALE_END := 1.5
const PLANET_ALPHA := 0.85
const CRASH_FLASH_DURATION := 1.2

var _env: Environment
var _sky_mat: ProceduralSkyMaterial
var _mars: MeshInstance3D
var _planet_ai: MeshInstance3D
var _flash: ColorRect

func _ready() -> void:
	LoopManager.progress_changed.connect(_on_progress_changed)
	LoopManager.loop_ended.connect(_on_loop_ended)

func setup(env: Environment, sky_mat: ProceduralSkyMaterial) -> void:
	_env = env
	_sky_mat = sky_mat
	var mars_tint := Color(0.95, 0.58, 0.28, PLANET_ALPHA)
	_mars = _build_planet(MARS_POSITION, _mars_texture(), mars_tint, Color(0.55, 0.25, 0.08))
	var ai_tint := Color(0.38, 0.40, 0.38, PLANET_ALPHA)
	var ai_emission := Color(0.08, 0.10, 0.09)
	_planet_ai = _build_planet(PLANET_AI_POSITION, _planet_ai_texture(), ai_tint, ai_emission)
	_build_flash()
	update_sky(0.0)

func _build_planet(pos: Vector3, tex: ImageTexture, tint: Color, emission: Color) -> MeshInstance3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = tex
	mat.albedo_color = tint
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.disable_fog = true
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = 0.5
	var mesh := SphereMesh.new()
	mesh.radius = 30.0
	mesh.height = 60.0
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi

func _mars_texture() -> ImageTexture:
	var size := 128
	var img := Image.create(size, size, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2107
	var c1 := Color(0.50, 0.20, 0.06)
	var c2 := Color(0.95, 0.55, 0.25)
	for y in range(size):
		for x in range(size):
			img.set_pixel(x, y, c1.lerp(c2, rng.randf()))
	for i in range(7):
		var c := Vector2(rng.randi_range(10, size - 10), rng.randi_range(10, size - 10))
		var r := rng.randf_range(4.0, 13.0)
		for y in range(size):
			for x in range(size):
				var d := Vector2(x, y).distance_to(c)
				if d < r:
					img.set_pixel(x, y, img.get_pixel(x, y) * 0.55)
				elif d < r + 2.0:
					img.set_pixel(x, y, img.get_pixel(x, y) * 1.25)
	return ImageTexture.create_from_image(img)

func _planet_ai_texture() -> ImageTexture:
	var size := 128
	var img := Image.create(size, size, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2098
	var base := Color(0.30, 0.32, 0.31)
	for y in range(size):
		for x in range(size):
			img.set_pixel(x, y, base * rng.randf_range(0.85, 1.15))
	for i in range(0, size, 16):
		for t in range(size):
			img.set_pixel(i, t, base * 0.7)
			img.set_pixel(t, i, base * 0.7)
	var dish := Vector2(46, 42)
	var r := 20.0
	for y in range(size):
		for x in range(size):
			var d := Vector2(x, y).distance_to(dish)
			if d < r - 2.0:
				img.set_pixel(x, y, base * 0.45)
			elif d < r:
				img.set_pixel(x, y, base * 1.4)
	for y in range(62, 66):
		for x in range(size):
			img.set_pixel(x, y, base * 0.6)
	return ImageTexture.create_from_image(img)

func _build_flash() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	_flash = ColorRect.new()
	_flash.color = Color(1.0, 0.25, 0.12)
	_flash.modulate.a = 0.0
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_flash)
	add_child(layer)

func _on_progress_changed(p: float) -> void:
	update_sky(p)

func update_sky(p: float) -> void:
	_sky_mat.sky_top_color = SKY_TOP_START.lerp(SKY_TOP_END, p)
	_sky_mat.sky_horizon_color = SKY_HOR_START.lerp(SKY_HOR_END, p)
	_sky_mat.ground_horizon_color = FOG_START.lerp(FOG_END, p)
	_env.fog_light_color = FOG_START.lerp(FOG_END, p)
	_env.fog_density = lerpf(FOG_DENSITY_START, FOG_DENSITY_END, p)
	var mars_s := lerpf(MARS_SCALE_START, MARS_SCALE_END, p)
	_mars.scale = Vector3.ONE * mars_s
	_mars.rotation.y = p * 1.5
	var ai_s := lerpf(PLANET_AI_SCALE_START, PLANET_AI_SCALE_END, p)
	_planet_ai.scale = Vector3.ONE * ai_s
	_planet_ai.rotation.y = -p * 0.8

func _on_loop_ended() -> void:
	_mars.scale = Vector3.ONE * MARS_SCALE_END
	_planet_ai.scale = Vector3.ONE * PLANET_AI_SCALE_END
	var tween := create_tween()
	_flash.modulate.a = 1.0
	tween.tween_property(_flash, "modulate:a", 0.0, CRASH_FLASH_DURATION)
