extends RefCounted

const SIZE := 32

static func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for py in range(y, y + h):
		for px in range(x, x + w):
			if px >= 0 and px < SIZE and py >= 0 and py < SIZE:
				img.set_pixel(px, py, c)

static func _circle(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for py in range(cy - r, cy + r + 1):
		for px in range(cx - r, cx + r + 1):
			if Vector2(px - cx, py - cy).length() <= r and px >= 0 and px < SIZE and py >= 0 and py < SIZE:
				img.set_pixel(px, py, c)

static func make_icon(kind: String) -> ImageTexture:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	if kind == "lampe":
		_rect(img, 10, 22, 12, 6, Color(0.35, 0.28, 0.2))
		_rect(img, 12, 12, 8, 10, Color(0.85, 0.75, 0.45))
		_rect(img, 14, 6, 4, 6, Color(0.95, 0.6, 0.2))
	elif kind == "radio":
		_rect(img, 6, 12, 20, 13, Color(0.25, 0.25, 0.28))
		_rect(img, 8, 8, 2, 5, Color(0.5, 0.5, 0.55))
		_circle(img, 16, 18, 4, Color(0.55, 0.55, 0.58))
		_rect(img, 22, 15, 2, 2, Color(0.7, 0.7, 0.7))
	elif kind == "livre":
		_rect(img, 8, 6, 16, 21, Color(0.85, 0.82, 0.72))
		_rect(img, 8, 6, 3, 21, Color(0.55, 0.4, 0.3))
		_rect(img, 13, 10, 8, 1, Color(0.6, 0.58, 0.52))
		_rect(img, 13, 14, 8, 1, Color(0.6, 0.58, 0.52))
	elif kind == "conserve":
		_rect(img, 10, 8, 12, 17, Color(0.6, 0.6, 0.62))
		_rect(img, 10, 8, 12, 3, Color(0.75, 0.75, 0.77))
		_rect(img, 10, 15, 12, 4, Color(0.45, 0.42, 0.38))
	else:
		_rect(img, 8, 8, 16, 16, Color(0.5, 0.5, 0.52))
	return ImageTexture.create_from_image(img)
