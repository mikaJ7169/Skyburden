import math
import struct
import zlib

from skyburden.raycaster import cast_ray

FOG_COLOR = (172, 180, 194)
CEIL_TOP = (26, 27, 38)
FLOOR_BOT = (20, 20, 26)
TEX_SIZE = 64


class Framebuffer:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.pixels = bytearray(width * height * 3)

    def set(self, x, y, color):
        if 0 <= x < self.width and 0 <= y < self.height:
            i = (y * self.width + x) * 3
            self.pixels[i] = color[0]
            self.pixels[i + 1] = color[1]
            self.pixels[i + 2] = color[2]

    def get(self, x, y):
        i = (y * self.width + x) * 3
        return (self.pixels[i], self.pixels[i + 1], self.pixels[i + 2])


def blend(c1, c2, t):
    return (
        int(c1[0] + (c2[0] - c1[0]) * t),
        int(c1[1] + (c2[1] - c1[1]) * t),
        int(c1[2] + (c2[2] - c1[2]) * t),
    )


def fog_amount(dist, max_view):
    if dist <= 0:
        return 0.0
    if dist >= max_view:
        return 1.0
    return (dist / max_view) ** 0.8


def render_frame(game_map, player, textures, width, height, fov=math.radians(66), max_view=14.0):
    fb = Framebuffer(width, height)
    horizon = height // 2
    for y in range(height):
        if y < horizon:
            t = 1.0 - y / max(1, horizon)
            color = blend(FOG_COLOR, CEIL_TOP, t)
        else:
            t = (y - horizon) / max(1, height - horizon)
            color = blend(FOG_COLOR, FLOOR_BOT, t)
        for x in range(width):
            fb.set(x, y, color)
    dir_x = math.cos(player.angle)
    dir_y = math.sin(player.angle)
    plane = math.tan(fov / 2.0)
    plane_x = -dir_y * plane
    plane_y = dir_x * plane
    for x in range(width):
        camera_x = 2.0 * x / width - 1.0
        rdx = dir_x + plane_x * camera_x
        rdy = dir_y + plane_y * camera_x
        perp, side, tex_char, wall_x = cast_ray(game_map.cells, player.x, player.y, rdx, rdy)
        line_h = int(height / max(perp, 1e-6))
        y0 = (height - line_h) // 2
        y1 = y0 + line_h
        tex = textures.get(tex_char) or textures["#"]
        tex_x = int(wall_x * TEX_SIZE)
        if (side == 0 and rdx > 0) or (side == 1 and rdy < 0):
            tex_x = TEX_SIZE - tex_x - 1
        shade = 0.62 if side == 1 else 1.0
        fog = fog_amount(perp, max_view)
        step = TEX_SIZE / max(line_h, 1)
        for y in range(max(y0, 0), min(y1, height)):
            tex_y = int((y - y0) * step) % TEX_SIZE
            c = tex[tex_y * TEX_SIZE + tex_x]
            c = (int(c[0] * shade), int(c[1] * shade), int(c[2] * shade))
            fb.set(x, y, blend(c, FOG_COLOR, fog))
    return fb


def write_png(path, width, height, rgb):
    def chunk(tag, data):
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    raw = bytearray()
    stride = width * 3
    for y in range(height):
        raw.append(0)
        raw.extend(rgb[y * stride:(y + 1) * stride])
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)
