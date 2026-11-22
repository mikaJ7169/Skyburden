import argparse
import os

from skyburden.game import run_demo
from skyburden.player import Player
from skyburden.render import render_frame, write_png
from skyburden.textures import make_textures
from skyburden.world import load_map


def main():
    parser = argparse.ArgumentParser(prog="skyburden", description="Prototype raycaster de Skyburden")
    parser.add_argument("--map", default="maps/acte1_zone1.txt", help="fichier de carte")
    parser.add_argument("--out", help="rend une seule image PNG (défaut: out/frame.png)")
    parser.add_argument("--demo", help="rend une séquence d'images dans ce dossier")
    parser.add_argument("--width", type=int, default=320)
    parser.add_argument("--height", type=int, default=200)
    args = parser.parse_args()

    game_map = load_map(args.map)
    player = Player(game_map.spawn_x, game_map.spawn_y, game_map.spawn_angle)
    textures = make_textures()

    if args.demo:
        for path in run_demo(game_map, player, textures, args.demo, args.width, args.height):
            print(path)
    else:
        out = args.out or os.path.join("out", "frame.png")
        os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
        fb = render_frame(game_map, player, textures, args.width, args.height)
        write_png(out, fb.width, fb.height, fb.pixels)
        print(out)


if __name__ == "__main__":
    main()
