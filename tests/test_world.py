import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from skyburden.world import GameMap, load_map

MAP_PATH = os.path.join(os.path.dirname(__file__), "..", "maps", "acte1_zone1.txt")


class TestLoadMap(unittest.TestCase):
    def test_charge_la_carte_du_projet(self):
        m = load_map(MAP_PATH)
        self.assertEqual(m.width, 24)
        self.assertEqual(m.height, 16)
        self.assertTrue(1.0 < m.spawn_x < m.width - 1.0)
        self.assertTrue(1.0 < m.spawn_y < m.height - 1.0)

    def test_bordure_murale(self):
        m = load_map(MAP_PATH)
        for x in range(m.width):
            self.assertTrue(m.is_wall(x, 0))
            self.assertTrue(m.is_wall(x, m.height - 1))
        for y in range(m.height):
            self.assertTrue(m.is_wall(0, y))
            self.assertTrue(m.is_wall(m.width - 1, y))

    def test_hors_limites_est_un_mur(self):
        m = GameMap([["#"]], 0.5, 0.5, 0.0, 1, 1)
        self.assertTrue(m.is_wall(-1, 0))
        self.assertTrue(m.is_wall(0, 5))

    def test_carte_non_rectangulaire_rejetee(self):
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
            f.write("###\n#P\n###\n")
            path = f.name
        try:
            with self.assertRaises(ValueError):
                load_map(path)
        finally:
            os.unlink(path)

    def test_sans_spawn_rejetee(self):
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
            f.write("###\n#.#\n###\n")
            path = f.name
        try:
            with self.assertRaises(ValueError):
                load_map(path)
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()
