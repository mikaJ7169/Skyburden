import math
import os
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from skyburden.player import Player
from skyburden.render import blend, fog_amount, render_frame, write_png
from skyburden.textures import TEX_SIZE, make_textures
from skyburden.world import GameMap


def make_room():
    cells = [
        list("########"),
        list("#......#"),
        list("#......#"),
        list("#......#"),
        list("#......#"),
        list("#......#"),
        list("########"),
    ]
    return GameMap(cells, 4.5, 3.5, 0.0, 8, 7)


class TestFog(unittest.TestCase):
    def test_bornes(self):
        self.assertEqual(fog_amount(0, 14), 0.0)
        self.assertEqual(fog_amount(14, 14), 1.0)
        self.assertEqual(fog_amount(99, 14), 1.0)

    def test_monotone(self):
        vals = [fog_amount(d, 14) for d in range(0, 15)]
        self.assertEqual(vals, sorted(vals))

    def test_blend_extremes(self):
        c = (10, 20, 30)
        f = (200, 210, 220)
        self.assertEqual(blend(c, f, 0.0), c)
        self.assertEqual(blend(c, f, 1.0), f)


class TestRender(unittest.TestCase):
    def test_framebuffer_dimensions(self):
        m = make_room()
        p = Player(4.5, 3.5, 0.0)
        fb = render_frame(m, p, make_textures(), 64, 40)
        self.assertEqual(len(fb.pixels), 64 * 40 * 3)

    def test_image_non_uniforme(self):
        m = make_room()
        p = Player(4.5, 3.5, 0.0)
        fb = render_frame(m, p, make_textures(), 64, 40)
        colors = {fb.get(x, 20) for x in range(64)}
        self.assertGreater(len(colors), 4)

    def test_mur_proche_plus_lumineux_que_brouillard(self):
        m = make_room()
        p = Player(1.5, 3.5, 0.0)
        fb = render_frame(m, p, make_textures(), 64, 40, max_view=14.0)
        near = sum(fb.get(32, 20))
        far_corner = sum(fb.get(0, 20))
        self.assertGreater(near, far_corner)

    def test_png_valide(self):
        m = make_room()
        p = Player(4.5, 3.5, 0.0)
        fb = render_frame(m, p, make_textures(), 32, 20)
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "f.png")
            write_png(path, fb.width, fb.height, fb.pixels)
            with open(path, "rb") as f:
                data = f.read()
        self.assertTrue(data.startswith(b"\x89PNG\r\n\x1a\n"))
        self.assertEqual(data[12:16], b"IHDR")
        w, h = struct.unpack(">II", data[16:24])
        self.assertEqual((w, h), (32, 20))
        self.assertTrue(data.rstrip().endswith(b"IEND\xaeB`\x82"))

    def test_textures_couvrent_la_grille(self):
        textures = make_textures()
        for key in ("#", "B", "W"):
            self.assertEqual(len(textures[key]), TEX_SIZE * TEX_SIZE)


if __name__ == "__main__":
    unittest.main()
