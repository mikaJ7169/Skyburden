import math

RAY_EPS = 1e30
MAX_STEPS = 128


def cast_ray(cells, px, py, rdx, rdy):
    map_x = int(px)
    map_y = int(py)
    delta_x = abs(1.0 / rdx) if rdx != 0 else RAY_EPS
    delta_y = abs(1.0 / rdy) if rdy != 0 else RAY_EPS
    if rdx < 0:
        step_x = -1
        side_x = (px - map_x) * delta_x
    else:
        step_x = 1
        side_x = (map_x + 1.0 - px) * delta_x
    if rdy < 0:
        step_y = -1
        side_y = (py - map_y) * delta_y
    else:
        step_y = 1
        side_y = (map_y + 1.0 - py) * delta_y
    side = 0
    tex_char = "#"
    for _ in range(MAX_STEPS):
        if side_x < side_y:
            side_x += delta_x
            map_x += step_x
            side = 0
        else:
            side_y += delta_y
            map_y += step_y
            side = 1
        if map_y < 0 or map_y >= len(cells) or map_x < 0 or map_x >= len(cells[map_y]):
            tex_char = "#"
            break
        cell = cells[map_y][map_x]
        if cell != ".":
            tex_char = cell
            break
    if side == 0:
        perp = (map_x - px + (1 - step_x) / 2.0) / rdx
    else:
        perp = (map_y - py + (1 - step_y) / 2.0) / rdy
    if side == 0:
        wall_x = py + perp * rdy
    else:
        wall_x = px + perp * rdx
    wall_x -= math.floor(wall_x)
    return perp, side, tex_char, wall_x
