extends RefCounted

const SIZE := 128
const MARGIN := 4

static func _rng(seed: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed
	return r

static func _shade(c: Color, n: float) -> Color:
	return Color(clampf(c.r + n, 0.0, 1.0), clampf(c.g + n, 0.0, 1.0), clampf(c.b + n, 0.0, 1.0))

static func _tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

static func _base_img(c: Color) -> Image:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	img.fill(c)
	return img

static func _noise_layer(img: Image, seed: int, amp: float, grid: int) -> void:
	var rng := _rng(seed)
	var vals: Array[float] = []
	for i in range(grid * grid):
		vals.append(rng.randf())
	for y in range(SIZE):
		for x in range(SIZE):
			var gx := float(x) / SIZE * grid
			var gy := float(y) / SIZE * grid
			var x0 := int(gx) % grid
			var y0 := int(gy) % grid
			var x1 := (x0 + 1) % grid
			var y1 := (y0 + 1) % grid
			var fx := gx - floorf(gx)
			var fy := gy - floorf(gy)
			var v00 := vals[y0 * grid + x0]
			var v10 := vals[y0 * grid + x1]
			var v01 := vals[y1 * grid + x0]
			var v11 := vals[y1 * grid + x1]
			var v := lerpf(lerpf(v00, v10, fx), lerpf(v01, v11, fx), fy)
			var c := img.get_pixel(x, y)
			var f := 1.0 - amp + v * 2.0 * amp
			img.set_pixel(x, y, Color(clampf(c.r * f, 0, 1), clampf(c.g * f, 0, 1), clampf(c.b * f, 0, 1)))

static func _smooth_noise(img: Image, seed: int) -> void:
	_noise_layer(img, seed * 7 + 1, 0.20, 4)
	_noise_layer(img, seed * 7 + 2, 0.10, 16)
	_noise_layer(img, seed * 7 + 3, 0.05, 64)

static func _blocks(
	img: Image, rng: RandomNumberGenerator, base: Color, mortar: Color,
	cw: int, ch: int, offset_rows := false
) -> void:
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var row := y / ch
			var off := cw / 2 if (offset_rows and row % 2 == 1) else 0
			var col := (x + off) / cw
			var key := str(col) + "," + str(row)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.85, 1.15)
			var lx := (x + off) % cw
			var ly := y % ch
			var c: Color
			if lx < 2 or ly < 2:
				c = mortar
			elif lx < 4 or ly < 4:
				c = base * shades[key] * 1.18
			elif lx >= cw - 2 or ly >= ch - 2:
				c = base * shades[key] * 0.65
			else:
				c = base * shades[key]
			img.set_pixel(x, y, _shade(c, rng.randf_range(-0.03, 0.03)))

static func _blotch(
	img: Image, rng: RandomNumberGenerator, count: int, color: Color, max_r: int
) -> void:
	for i in range(count):
		var cx := rng.randi_range(max_r + MARGIN, SIZE - max_r - MARGIN - 1)
		var cy := rng.randi_range(max_r + MARGIN, SIZE - max_r - MARGIN - 1)
		var r := rng.randi_range(3, max_r)
		for y in range(cy - r, cy + r + 1):
			for x in range(cx - r, cx + r + 1):
				var d := Vector2(x - cx, y - cy).length()
				if d <= r:
					var f := 1.0 - d / r
					img.set_pixel(x, y, img.get_pixel(x, y).lerp(color, f * 0.5))

static func _cracks(img: Image, rng: RandomNumberGenerator, count: int, color: Color) -> void:
	for i in range(count):
		var x := rng.randi_range(MARGIN, SIZE - MARGIN - 1)
		var y := rng.randi_range(MARGIN, SIZE - MARGIN - 1)
		for j in range(rng.randi_range(6, 30)):
			img.set_pixel(x, y, color)
			x = clampi(x + rng.randi_range(-1, 1), MARGIN - 1, SIZE - MARGIN)
			y = clampi(y + rng.randi_range(-1, 1), MARGIN - 1, SIZE - MARGIN)

static func _moss(img: Image, rng: RandomNumberGenerator, count: int) -> void:
	for i in range(count):
		var x := rng.randi_range(MARGIN + 2, SIZE - MARGIN - 3)
		var y := rng.randi_range(MARGIN + 2, SIZE - MARGIN - 3)
		for j in range(rng.randi_range(4, 14)):
			var c := img.get_pixel(x, y)
			img.set_pixel(x, y, Color(c.r * 0.72, minf(1.0, c.g * 1.08 + 0.05), c.b * 0.72))
			x = clampi(x + rng.randi_range(-1, 1), MARGIN, SIZE - MARGIN - 1)
			y = clampi(y + rng.randi_range(-1, 1), MARGIN, SIZE - MARGIN - 1)

static func make_stone() -> ImageTexture:
	var rng := _rng(1101)
	var img := _base_img(Color(0.56, 0.54, 0.51))
	_blocks(img, rng, Color(0.56, 0.54, 0.51), Color(0.30, 0.29, 0.28), 32, 32)
	_smooth_noise(img, 1101)
	_cracks(img, rng, 6, Color(0.18, 0.17, 0.16))
	_moss(img, rng, 9)
	return _tex(img)

static func make_brick() -> ImageTexture:
	var rng := _rng(2202)
	var img := _base_img(Color(0.5, 0.26, 0.2))
	_blocks(img, rng, Color(0.5, 0.26, 0.2), Color(0.42, 0.4, 0.38), 32, 16, true)
	_smooth_noise(img, 2202)
	_blotch(img, rng, 6, Color(0.3, 0.16, 0.12), 10)
	_cracks(img, rng, 4, Color(0.22, 0.14, 0.1))
	return _tex(img)

static func make_plaster() -> ImageTexture:
	var rng := _rng(9909)
	var img := _base_img(Color(0.6, 0.58, 0.53))
	_smooth_noise(img, 9909)
	_blotch(img, rng, 8, Color(0.45, 0.43, 0.38), 14)
	_cracks(img, rng, 6, Color(0.38, 0.36, 0.32))
	return _tex(img)

static func make_dirt() -> ImageTexture:
	var rng := _rng(8808)
	var img := _base_img(Color(0.33, 0.29, 0.23))
	_smooth_noise(img, 8808)
	_blotch(img, rng, 14, Color(0.24, 0.2, 0.15), 18)
	_blotch(img, rng, 8, Color(0.42, 0.38, 0.3), 12)
	for i in range(30):
		var x := rng.randi_range(MARGIN, SIZE - MARGIN - 1)
		var y := rng.randi_range(MARGIN, SIZE - MARGIN - 1)
		img.set_pixel(x, y, Color(0.44, 0.43, 0.4))
	for i in range(16):
		var x := rng.randi_range(MARGIN, SIZE - MARGIN - 2)
		var y := rng.randi_range(MARGIN, SIZE - MARGIN - 2)
		img.set_pixel(x, y, Color(0.42, 0.5, 0.34))
		img.set_pixel(x, clampi(y + 1, 0, SIZE - 1), Color(0.38, 0.47, 0.31))
	_cracks(img, rng, 5, Color(0.2, 0.17, 0.13))
	return _tex(img)

static func make_wood() -> ImageTexture:
	var rng := _rng(5505)
	var img := _base_img(Color(0.42, 0.31, 0.19))
	var pw := 32
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var plank := x / pw
			var key := str(plank)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.82, 1.15)
			var lx := x % pw
			var c: Color
			if lx < 2:
				c = Color(0.2, 0.14, 0.08)
			elif lx == 2:
				c = Color(0.5, 0.38, 0.23) * shades[key]
			elif lx == 8 or lx == 19 or lx == 27:
				c = Color(0.42, 0.31, 0.19) * shades[key] * 0.78
			else:
				c = Color(0.42, 0.31, 0.19) * shades[key]
			img.set_pixel(x, y, _shade(c, rng.randf_range(-0.03, 0.03)))
	_smooth_noise(img, 5505)
	for i in range(4):
		var kx := rng.randi_range(MARGIN + 3, SIZE - MARGIN - 4)
		var ky := rng.randi_range(MARGIN + 3, SIZE - MARGIN - 4)
		for y in range(ky - 2, ky + 3):
			for x in range(kx - 2, kx + 3):
				if Vector2(x - kx, y - ky).length() < 2.5:
					img.set_pixel(x, y, Color(0.2, 0.14, 0.08))
	return _tex(img)

static func make_roof() -> ImageTexture:
	var rng := _rng(7707)
	var img := _base_img(Color(0.4, 0.38, 0.36))
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var row := y / 16
			var off := 8 if row % 2 == 1 else 0
			var key := str((x + off) / 16) + "," + str(row)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.85, 1.15)
			var lx := (x + off) % 16
			var ly := y % 16
			var c: Color
			if ly < 2 or lx < 2:
				c = Color(0.22, 0.21, 0.2)
			elif ly < 5:
				c = Color(0.4, 0.38, 0.36) * shades[key] * 0.8
			elif ly >= 13:
				c = Color(0.4, 0.38, 0.36) * shades[key] * 1.12
			else:
				c = Color(0.4, 0.38, 0.36) * shades[key]
			img.set_pixel(x, y, _shade(c, rng.randf_range(-0.03, 0.03)))
	_smooth_noise(img, 7707)
	return _tex(img)

static func make_concrete() -> ImageTexture:
	var rng := _rng(3303)
	var img := _base_img(Color(0.47, 0.47, 0.49))
	_smooth_noise(img, 3303)
	_blotch(img, rng, 8, Color(0.36, 0.36, 0.38), 12)
	_cracks(img, rng, 5, Color(0.28, 0.28, 0.3))
	return _tex(img)

static func make_metal() -> ImageTexture:
	var rng := _rng(6606)
	var img := _base_img(Color(0.34, 0.35, 0.39))
	_smooth_noise(img, 6606)
	for i in range(10):
		var x := rng.randi_range(MARGIN, SIZE - MARGIN - 1)
		for y in range(SIZE):
			img.set_pixel(x, y, img.get_pixel(x, y) * 0.85)
	_blotch(img, rng, 6, Color(0.42, 0.26, 0.16), 8)
	return _tex(img)
