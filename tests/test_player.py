import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from skyburden.player import Player
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


class TestPlayer(unittest.TestCase):
    def test_avance_dans_la_direction_regardee(self):
        m = make_room()
        p = Player(2.5, 2.5, 0.0)
        p.move(m, 0.5)
        self.assertAlmostEqual(p.x, 3.0)
        self.assertAlmostEqual(p.y, 2.5)

    def test_mur_bloque(self):
        m = make_room()
        p = Player(2.5, 2.5, 0.0)
        p.move(m, 10.0)
        self.assertLess(p.x, 4.0)
        self.assertGreater(p.x, 2.5)

    def test_glissement_le_long_du_mur(self):
        m = make_room()
        p = Player(1.2, 2.5, 0.0)
        p.move(m, 5.0, strafe=0.5)
        self.assertGreater(p.y, 2.5)

    def test_rotation(self):
        p = Player(0, 0, 0.0)
        p.turn(1.0)
        self.assertAlmostEqual(p.angle, 1.0)


if __name__ == "__main__":
    unittest.main()
