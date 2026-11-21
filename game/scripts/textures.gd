extends RefCounted

const SIZE := 64

static func _rng(seed: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed
	return r

static func _shade(c: Color, n: float) -> Color:
	return Color(clampf(c.r + n, 0.0, 1.0), clampf(c.g + n, 0.0, 1.0), clampf(c.b + n, 0.0, 1.0))

static func _noise(seed: int, base: Color, jitter: float) -> ImageTexture:
	var rng := _rng(seed)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	for y in range(SIZE):
		for x in range(SIZE):
			img.set_pixel(x, y, _shade(base, rng.randf_range(-jitter, jitter)))
	return ImageTexture.create_from_image(img)

static func _grid(seed: int, base: Color, line: Color, cell: int, jitter: float) -> ImageTexture:
	var rng := _rng(seed)
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	for y in range(SIZE):
		for x in range(SIZE):
			var on_line := y % cell == cell - 1 or x % cell == cell - 1
			var c := line if on_line else base
			img.set_pixel(x, y, _shade(c, rng.randf_range(-jitter, jitter)))
	return ImageTexture.create_from_image(img)

static func make_stone() -> ImageTexture:
	return _grid(1101, Color(0.62, 0.60, 0.57), Color(0.36, 0.35, 0.34), 16, 0.06)

static func make_brick() -> ImageTexture:
	return _grid(2202, Color(0.52, 0.28, 0.22), Color(0.40, 0.38, 0.36), 8, 0.05)

static func make_concrete() -> ImageTexture:
	return _noise(3303, Color(0.48, 0.48, 0.50), 0.05)

static func make_floor() -> ImageTexture:
	return _grid(4404, Color(0.40, 0.40, 0.43), Color(0.26, 0.26, 0.28), 32, 0.05)

static func make_wood() -> ImageTexture:
	return _grid(5505, Color(0.45, 0.33, 0.20), Color(0.25, 0.18, 0.11), 16, 0.05)

static func make_metal() -> ImageTexture:
	return _noise(6606, Color(0.35, 0.36, 0.40), 0.06)
