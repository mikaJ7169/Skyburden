import math
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from skyburden.raycaster import cast_ray
from skyburden.world import GameMap


def make_room():
    cells = [
        list("#####"),
        list("#...#"),
        list("#...#"),
        list("#...#"),
        list("#####"),
    ]
    return GameMap(cells, 2.5, 2.5, 0.0, 5, 5)


class TestCastRay(unittest.TestCase):
    def test_ray_droit_horizontal(self):
        m = make_room()
        perp, side, tex, wall_x = cast_ray(m.cells, 2.5, 2.5, 1.0, 0.0)
        self.assertAlmostEqual(perp, 1.5)
        self.assertEqual(side, 0)
        self.assertEqual(tex, "#")

    def test_ray_droit_vertical(self):
        m = make_room()
        perp, side, tex, wall_x = cast_ray(m.cells, 2.5, 2.5, 0.0, 1.0)
        self.assertAlmostEqual(perp, 1.5)
        self.assertEqual(side, 1)

    def test_ray_vers_la_gauche(self):
        m = make_room()
        perp, side, tex, wall_x = cast_ray(m.cells, 2.5, 2.5, -1.0, 0.0)
        self.assertAlmostEqual(perp, 1.5)
        self.assertEqual(side, 0)

    def test_distance_perpendiculaire_sans_fisheye(self):
        m = make_room()
        angle = math.radians(30)
        rdx = math.cos(angle)
        rdy = math.sin(angle)
        perp, side, tex, wall_x = cast_ray(m.cells, 2.5, 2.5, rdx, rdy)
        euclid = perp / math.cos(angle - angle)
        self.assertAlmostEqual(perp, euclid)
        perp2, _, _, _ = cast_ray(m.cells, 2.5, 2.5, rdx, rdy)
        self.assertAlmostEqual(perp, perp2)

    def test_texture_selon_le_mur(self):
        cells = [
            list("#####"),
            list("#..B#"),
            list("#####"),
        ]
        m = GameMap(cells, 1.5, 1.5, 0.0, 5, 3)
        _, _, tex, _ = cast_ray(m.cells, 1.5, 1.5, 1.0, 0.0)
        self.assertEqual(tex, "B")

    def test_wall_x_dans_les_bornes(self):
        m = make_room()
        for i in range(21):
            a = -math.pi + i * (2 * math.pi / 20)
            _, _, _, wall_x = cast_ray(m.cells, 2.5, 2.5, math.cos(a), math.sin(a))
            self.assertTrue(0.0 <= wall_x < 1.0)


if __name__ == "__main__":
    unittest.main()
