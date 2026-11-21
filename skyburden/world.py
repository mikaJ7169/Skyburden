import math
from dataclasses import dataclass

SPAWN_ANGLES = {
    "P": 0.0,
    ">": 0.0,
    "v": math.pi / 2,
    "<": math.pi,
    "^": -math.pi / 2,
}


@dataclass
class GameMap:
    cells: list
    spawn_x: float
    spawn_y: float
    spawn_angle: float
    width: int
    height: int

    def is_wall(self, x, y):
        ix = int(x)
        iy = int(y)
        if ix < 0 or iy < 0 or iy >= self.height or ix >= self.width:
            return True
        return self.cells[iy][ix] != "."


def load_map(path):
    with open(path, encoding="utf-8") as f:
        rows = [line.rstrip("\n") for line in f if line.strip()]
    if not rows:
        raise ValueError("carte vide")
    width = len(rows[0])
    if any(len(row) != width for row in rows):
        raise ValueError("carte non rectangulaire")
    cells = []
    spawn = None
    for y, row in enumerate(rows):
        cells_row = []
        for x, ch in enumerate(row):
            if ch in SPAWN_ANGLES:
                if spawn is not None:
                    raise ValueError("plusieurs points de départ")
                spawn = (x + 0.5, y + 0.5, SPAWN_ANGLES[ch])
                cells_row.append(".")
            else:
                cells_row.append(ch)
        cells.append(cells_row)
    if spawn is None:
        raise ValueError("pas de point de départ dans la carte")
    for x in range(width):
        if cells[0][x] == "." or cells[-1][x] == ".":
            raise ValueError("la carte doit être fermée par des murs")
    for y in range(len(rows)):
        if cells[y][0] == "." or cells[y][-1] == ".":
            raise ValueError("la carte doit être fermée par des murs")
    return GameMap(cells, spawn[0], spawn[1], spawn[2], width, len(rows))
