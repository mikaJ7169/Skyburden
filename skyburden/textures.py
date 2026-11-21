import random

TEX_SIZE = 64


def _noise_pixels(rng, base, spread):
    return [(max(0, min(255, c + rng.randint(-spread, spread))) for c in base) for _ in range(TEX_SIZE * TEX_SIZE)]


def _stone(rng):
    base = (104, 100, 96)
    px = []
    for y in range(TEX_SIZE):
        band = (y // 16) % 2
        for x in range(TEX_SIZE):
            mortar = y % 16 == 15 or x % 16 == (0 if band == 0 else 8)
            n = rng.randint(-12, 12)
            if mortar:
                px.append((62, 60, 58))
            else:
                px.append((max(0, base[0] + n), max(0, base[1] + n), max(0, base[2] + n)))
    return px


def _brick(rng):
    base = (122, 62, 50)
    px = []
    for y in range(TEX_SIZE):
        band = (y // 8) % 2
        for x in range(TEX_SIZE):
            mortar = y % 8 == 7 or x % 16 == (0 if band == 0 else 8)
            n = rng.randint(-10, 10)
            if mortar:
                px.append((70, 66, 62))
            else:
                px.append((max(0, base[0] + n), max(0, base[1] + n), max(0, base[2] + n)))
    return px


def _wood(rng):
    base = (112, 82, 50)
    px = []
    for y in range(TEX_SIZE):
        for x in range(TEX_SIZE):
            seam = x % 16 == 0
            grain = rng.randint(-8, 8) + (6 if (x % 16) % 3 == 0 else 0)
            if seam:
                px.append((58, 42, 26))
            else:
                px.append((max(0, base[0] + grain), max(0, base[1] + grain), max(0, base[2] + grain)))
    return px


def make_textures():
    return {
        "#": _stone(random.Random(1101)),
        "B": _brick(random.Random(2202)),
        "W": _wood(random.Random(3303)),
    }
