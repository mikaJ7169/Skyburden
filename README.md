# Skyburden — Le Poids du Ciel

> *Le monde se disloque. Les montagnes se décrochent de la terre, attirées par une force inconnue. Les survivants ont tout oublié. Quelqu'un, quelque part, sait la vérité.*

**Skyburden** est un jeu PC solo d'exploration et de narration dans un monde en ruine, en cours de dislocation physique. Ambiance dystopique, solitude permanente, visuel rétro-3D type début des années 90 (DOOM, Basilisk 2000).

## Statut

**Phase : prototype technique + écriture du scénario et du lore.**

Un premier prototype jouable existe : un raycaster rétro-3D en Python pur (aucune dépendance), conforme à la vision (brouillard de distance, textures basse résolution). Le choix du moteur définitif (Godot, moteur raycasting dédié, etc.) reste ouvert.

## Pitch

- Un monde littéralement en train de se disloquer : bâtiments, villes, montagnes arrachés au sol par une force inconnue.
- Une société régressée au Moyen-Âge : l'oubli de l'ancien monde a été organisé.
- L'ancien monde ≈ notre monde réel + 100 ans (vers 2125).
- Un tyran fasciste qui connaît la vérité, ne peut rien y changer — et ne le voudrait pas.
- Une solitude qui traverse tout le jeu : peu de PNJ, pas de foule, du silence.

## Structure du projet

```
docs/
├── design/
│   ├── vision.md      # Ambiance, références visuelles, ton
│   └── gameplay.md    # Pistes de mécaniques (provisoire)
├── lore/
│   ├── monde.md       # La dislocation, les strates, la chronologie
│   └── factions.md    # Le tyran, l'Église de l'Ancrage, les Mnémos
└── scenario/
    └── synopsis.md    # Synopsis en trois actes (brouillon)

skyburden/             # prototype raycaster (Python stdlib uniquement)
├── world.py           # chargement des cartes (texte)
├── raycaster.py       # lancer de rayons (DDA)
├── textures.py        # textures procédurales 64x64
├── render.py          # framebuffer, brouillard, écriture PNG
├── player.py          # déplacement et collisions
└── game.py            # démo scriptée (headless)
main.py                # point d'entrée
maps/                  # cartes en texte (# mur, B brique, W bois, P départ)
tests/                 # tests unitaires (unittest)
```

## Lancer le prototype

```bash
python3 main.py --out out/frame.png            # une image à la position de départ
python3 main.py --demo out/demo                 # une séquence de déplacements
python3 -m unittest discover -s tests           # tests
```

## Nom

- **Titre** : *Skyburden*
- **Sous-titre français** : *Le Poids du Ciel*
- **Nom technique / repo** : `skyburden`
