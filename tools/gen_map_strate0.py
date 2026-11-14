#!/usr/bin/env python3
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Circle, Rectangle, FancyBboxPatch
from matplotlib.lines import Line2D
import numpy as np

fig, ax = plt.subplots(figsize=(16, 11.5), dpi=130)
fig.patch.set_facecolor("#10121a")
ax.set_facecolor("#10121a")
ax.set_xlim(0, 160)
ax.set_ylim(0, 115)
ax.axis("off")

LAND = "#2e3138"
LAND2 = "#383c45"
VOID = "#10121a"
EDGE = "#8a2f2f"
TXT = "#d8d4c8"
SUB = "#9a968c"

# ---------- Le vide autour ----------
ax.add_patch(Rectangle((0, 0), 160, 115, facecolor=VOID, zorder=0))

# ---------- Terre ferme (strate la plus basse) ----------
land = [(18, 8), (60, 4), (105, 6), (138, 14), (150, 34), (142, 60),
        (146, 82), (128, 96), (100, 104), (70, 108), (44, 100), (24, 84),
        (14, 62), (16, 34)]
ax.add_patch(Polygon(land, closed=True, facecolor=LAND, edgecolor="#565a64", lw=2, zorder=1))

# relief simple (collines)
for (cx, cy, w, h) in [(52, 88, 26, 9), (92, 70, 20, 7), (118, 40, 22, 8), (38, 52, 16, 6)]:
    ax.add_patch(Polygon([(cx-w, cy), (cx-w/3, cy+h), (cx+w/3, cy+h*0.7), (cx+w, cy)],
                         closed=True, facecolor=LAND2, edgecolor="none", zorder=2))

# ---------- Limite d'arrachement (nord) ----------
tear = [(44, 100), (70, 108), (100, 104), (128, 96), (146, 82), (150, 74),
        (138, 80), (120, 90), (96, 97), (66, 100), (40, 93)]
ax.add_patch(Polygon(tear, closed=True, facecolor="none", edgecolor=EDGE, lw=2.5, hatch="xx", zorder=3, alpha=0.9))
ax.text(97, 112, "LIMITE D'ARRACHEMENT — le sol se soulève", ha="center", fontsize=12,
        color=EDGE, weight="bold", zorder=6)

# fragments flottants (arrachés)
for (cx, cy, s, rot) in [(158, 92, 5, 0.3), (163, 78, 3.5, -0.2), (156, 104, 4, 0.5)]:
    pts = [(cx-s, cy), (cx-s/2, cy+s*0.8), (cx+s/2, cy+s), (cx+s, cy+s/3)]
    ax.add_patch(Polygon(pts, closed=True, facecolor="#3c4048", edgecolor="#6a6e78", lw=1, zorder=3))
ax.text(163, 68, "fragments\narrachés", ha="center", fontsize=8, color=SUB, style="italic", zorder=6)

# ---------- Anciennes routes ----------
for (x1, y1, x2, y2) in [(80, 52, 120, 40), (80, 52, 46, 70), (80, 52, 84, 86),
                          (80, 52, 40, 26), (80, 52, 118, 24), (46, 70, 30, 88)]:
    ax.add_line(Line2D([x1, x2], [y1, y2], color="#5a5e68", lw=1.2, ls=(0, (4, 3)), zorder=2))

# ---------- Symboles ----------
def group(x, y, color):
    ax.add_patch(Circle((x, y), 2.2, facecolor=color, edgecolor=TXT, lw=1.2, zorder=5))

def ruin(x, y, color="#8a6d3b"):
    ax.add_patch(Rectangle((x-2.2, y-2.2), 4.4, 4.4, facecolor="none",
                           edgecolor=color, lw=1.6, zorder=5))

def label(x, y, name, desc, dy=4.5, color=TXT):
    ax.text(x, y+dy, name, ha="center", fontsize=10.5, color=color, weight="bold", zorder=6)
    ax.text(x, y+dy-3.4, desc, ha="center", fontsize=8, color=SUB, style="italic", zorder=6)

# ---------- Lieux ----------
# Ville de départ
group(80, 52, "#c9b458")
label(80, 52, "LA VILLE D'ORIGINE (départ)", "le sous-sol du joueur · Ben le glaneur · ruines", dy=6)

# Religieux extrêmes
group(30, 88, "#b04a4a")
label(30, 88, "LE PRIEURÉ DE L'ANCRAGE", "religieux poussés à l'extrême · l'Église radicale", dy=5)

# Secte
group(118, 82, "#7a4fb0")
label(118, 82, "LA SECTE DU GOUFFRE", "vénère la force · vit au bord de l'arrachement", dy=5)

# Endeillés (fous de peine)
group(46, 70, "#4a7a8f")
label(46, 70, "LE VILLAGE DES ENDEILLÉS", "rendus fous par la perte de ceux qu'ils aimaient", dy=5)

# Gens simples
group(40, 26, "#6a9a5a")
label(40, 26, "LE HAMEAU DES SIMPLES", "vivaient paisibles avant le désastre · fermiers", dy=5)

# Ruines
ruin(120, 40)
label(120, 40, "RUINES INDUSTRIELLES", "usines de l'ancien monde · dangereuses", dy=5)
ruin(84, 86)
label(84, 86, "LA CATHÉDRALE GREFFÉE", "cathédrale sur centre commercial · ruine majeure", dy=5)
ruin(118, 24)
label(118, 24, "LE STADE-VILLAGE", "village médiéval dans un stade de foot", dy=5)
ruin(64, 34)
label(64, 34, "LA MURAILLE", "autoroute servant de muraille · vestiges de la guerre", dy=5)

# caches de la résistance (traces)
for (x, y) in [(58, 78), (104, 56), (92, 30)]:
    ax.text(x, y, "✕", ha="center", va="center", fontsize=11, color="#c9853b", zorder=6)
ax.text(104, 60.5, "traces de la résistance (Mnémos)", ha="center", fontsize=8,
        color="#c9853b", style="italic", zorder=6)

# ---------- Légende ----------
leg = [
    ("group", "Regroupement de personnes"),
    ("ruin", "Lieu de ruines"),
    ("tear", "Limite d'arrachement"),
    ("x", "Traces de la résistance"),
]
lx, ly = 4, 14
for i, (k, t) in enumerate(leg):
    y = ly - i*5
    if k == "group":
        ax.add_patch(Circle((lx+2, y), 1.6, facecolor="#888", edgecolor=TXT, lw=1))
    elif k == "ruin":
        ax.add_patch(Rectangle((lx+0.4, y-1.6), 3.2, 3.2, facecolor="none", edgecolor="#8a6d3b", lw=1.4))
    elif k == "tear":
        ax.add_patch(Rectangle((lx+0.4, y-1.6), 3.2, 3.2, facecolor="none", edgecolor=EDGE, lw=1.4, hatch="xx"))
    else:
        ax.text(lx+2, y, "✕", ha="center", va="center", fontsize=10, color="#c9853b")
    ax.text(lx+6, y-0.4, t, fontsize=9.5, color=TXT, va="center")

# ---------- Titre ----------
ax.text(80, 3, "SKYBURDEN — STRATE 0 : LA TERRE FERME (proposition à valider par l'auteur)",
        ha="center", fontsize=15, color=TXT, weight="bold")
ax.text(80, 121, "Carte de proposition — strate la plus basse du terrain",
        ha="center", fontsize=11, color=SUB, style="italic")

plt.tight_layout()
out = "/workspace/github__MikaJ7169__Skyburden/docs/carte/strate-0-proposition.png"
import os
os.makedirs(os.path.dirname(out), exist_ok=True)
plt.savefig(out, dpi=130, facecolor=fig.get_facecolor(), bbox_inches="tight")
print("OK", out)
