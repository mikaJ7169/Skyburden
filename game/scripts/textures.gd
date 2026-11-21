extends RefCounted

const SIZE := 128

static func _rng(seed: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed
	return r

static func _shade(c: Color, n: float) -> Color:
	return Color(clampf(c.r + n, 0.0, 1.0), clampf(c.g + n, 0.0, 1.0), clampf(c.b + n, 0.0, 1.0))

static func _tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

static func _noise_img(seed: int, base: Color, jitter: float) -> Image:
	var rng := _rng(seed)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	for y in range(SIZE):
		for x in range(SIZE):
			img.set_pixel(x, y, _shade(base, rng.randf_range(-jitter, jitter)))
	return img

static func _cracks(img: Image, rng: RandomNumberGenerator, count: int, color: Color) -> void:
	for i in range(count):
		var x := rng.randi_range(0, SIZE - 1)
		var y := rng.randi_range(0, SIZE - 1)
		for j in range(rng.randi_range(8, 40)):
			img.set_pixel(x, y, color)
			x = clampi(x + rng.randi_range(-1, 1), 0, SIZE - 1)
			y = clampi(y + rng.randi_range(-1, 1), 0, SIZE - 1)

static func _moss(img: Image, rng: RandomNumberGenerator, count: int) -> void:
	for i in range(count):
		var x := rng.randi_range(2, SIZE - 3)
		var y := rng.randi_range(2, SIZE - 3)
		for j in range(rng.randi_range(4, 16)):
			var c := img.get_pixel(x, y)
			img.set_pixel(x, y, Color(c.r * 0.75, minf(1.0, c.g * 1.08 + 0.06), c.b * 0.75))
			x = clampi(x + rng.randi_range(-1, 1), 0, SIZE - 1)
			y = clampi(y + rng.randi_range(-1, 1), 0, SIZE - 1)

static func make_stone() -> ImageTexture:
	var rng := _rng(1101)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	var cell := 32
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var key := str(x / cell) + "," + str(y / cell)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.82, 1.12)
			var on_line := x % cell < 2 or y % cell < 2
			var base := Color(0.34, 0.33, 0.32) if on_line else Color(0.58, 0.56, 0.53)
			var c: Color = base * shades[key]
			img.set_pixel(x, y, _shade(c, rng.randf_range(-0.04, 0.04)))
	_cracks(img, rng, 7, Color(0.20, 0.19, 0.18))
	_moss(img, rng, 10)
	return _tex(img)

static func make_brick() -> ImageTexture:
	var rng := _rng(2202)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	var bh := 16
	var bw := 32
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var row := y / bh
			var off := bw / 2 if row % 2 == 1 else 0
			var key := str((x + off) / bw) + "," + str(row)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.8, 1.15)
			var on_line := y % bh < 2 or (x + off) % bw < 2
			var base := Color(0.40, 0.38, 0.36) if on_line else Color(0.52, 0.27, 0.21)
			img.set_pixel(x, y, _shade(base * shades[key], rng.randf_range(-0.03, 0.03)))
	_cracks(img, rng, 4, Color(0.25, 0.16, 0.12))
	return _tex(img)

static func make_concrete() -> ImageTexture:
	var rng := _rng(3303)
	var img := _noise_img(3303, Color(0.48, 0.48, 0.50), 0.05)
	_cracks(img, rng, 5, Color(0.30, 0.30, 0.32))
	return _tex(img)

static func make_floor() -> ImageTexture:
	var rng := _rng(4404)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	var cell := 32
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var key := str(x / cell) + "," + str(y / cell)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.85, 1.15)
			var on_line := x % cell < 2 or y % cell < 2
			var base := Color(0.22, 0.22, 0.24) if on_line else Color(0.38, 0.38, 0.41)
			var c: Color = base * shades[key]
			if not on_line and rng.randf() < 0.03:
				c = c * 0.7
			img.set_pixel(x, y, _shade(c, rng.randf_range(-0.03, 0.03)))
	_cracks(img, rng, 6, Color(0.14, 0.14, 0.16))
	return _tex(img)

static func make_wood() -> ImageTexture:
	var rng := _rng(5505)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	var pw := 32
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var key := str(x / pw)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.8, 1.15)
			var seam := x % pw < 2
			var grain := x % pw == 9 or x % pw == 21
			var base := Color(0.42, 0.31, 0.19)
			if seam:
				base = Color(0.22, 0.16, 0.10)
			elif grain:
				base = base * 0.75
			img.set_pixel(x, y, _shade(base * shades[key], rng.randf_range(-0.03, 0.03)))
	for i in range(4):
		var kx := rng.randi_range(4, SIZE - 4)
		var ky := rng.randi_range(4, SIZE - 4)
		for y in range(ky - 2, ky + 3):
			for x in range(kx - 2, kx + 3):
				if Vector2(x - kx, y - ky).length() < 2.5:
					img.set_pixel(x, y, Color(0.20, 0.14, 0.08))
	return _tex(img)

static func make_roof() -> ImageTexture:
	var rng := _rng(7707)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	var shades := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var row := y / 16
			var key := str(x / 16) + "," + str(row)
			if not shades.has(key):
				shades[key] = rng.randf_range(0.8, 1.15)
			var on_h := y % 16 < 2
			var on_v := (x + (row % 2) * 8) % 16 < 2
			var base := Color(0.40, 0.38, 0.36)
			if on_h or on_v:
				base = Color(0.24, 0.23, 0.22)
			img.set_pixel(x, y, _shade(base * shades[key], rng.randf_range(-0.03, 0.03)))
	return _tex(img)

static func make_dirt() -> ImageTexture:
	var rng := _rng(8808)
	var img := _noise_img(8808, Color(0.36, 0.32, 0.26), 0.08)
	for i in range(24):
		var x := rng.randi_range(0, SIZE - 8)
		var y := rng.randi_range(0, SIZE - 8)
		var r := rng.randi_range(2, 7)
		for py in range(y, y + r):
			for px in range(x, x + r):
				if Vector2(px - x, py - y).length() < r:
					img.set_pixel(px, py, img.get_pixel(px, py) * rng.randf_range(0.7, 0.9))
	for i in range(40):
		var x := rng.randi_range(0, SIZE - 1)
		var y := rng.randi_range(0, SIZE - 1)
		img.set_pixel(x, y, Color(0.45, 0.44, 0.42))
	for i in range(14):
		var x := rng.randi_range(0, SIZE - 1)
		var y := rng.randi_range(0, SIZE - 1)
		img.set_pixel(x, y, Color(0.45, 0.52, 0.38))
		img.set_pixel(x, clampi(y + 1, 0, SIZE - 1), Color(0.42, 0.5, 0.36))
	_cracks(img, rng, 5, Color(0.22, 0.19, 0.15))
	return _tex(img)

static func make_plaster() -> ImageTexture:
	var rng := _rng(9909)
	var img := _noise_img(9909, Color(0.62, 0.60, 0.55), 0.04)
	_cracks(img, rng, 6, Color(0.4, 0.38, 0.34))
	return _tex(img)

static func make_metal() -> ImageTexture:
	var rng := _rng(6606)
	var img := _noise_img(6606, Color(0.35, 0.36, 0.40), 0.05)
	for x in range(SIZE):
		for y in range(SIZE):
			if x % 8 < 1:
				img.set_pixel(x, y, img.get_pixel(x, y) * 0.8)
	return _tex(img)
