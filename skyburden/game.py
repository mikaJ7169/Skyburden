import os

from skyburden.render import render_frame, write_png

DEMO_SCRIPT = [
    ("forward", 0.8),
    ("turn", 0.7),
    ("forward", 1.4),
    ("turn", -1.0),
    ("forward", 0.9),
    ("turn", 0.5),
    ("forward", 1.6),
    ("turn", -0.3),
]


def run_demo(game_map, player, textures, out_dir, width, height, script=DEMO_SCRIPT):
    os.makedirs(out_dir, exist_ok=True)
    paths = []
    for i, (action, amount) in enumerate(script):
        if action == "forward":
            player.move(game_map, amount)
        elif action == "turn":
            player.turn(amount)
        path = os.path.join(out_dir, f"frame_{i:02d}.png")
        fb = render_frame(game_map, player, textures, width, height)
        write_png(path, fb.width, fb.height, fb.pixels)
        paths.append(path)
    return paths
