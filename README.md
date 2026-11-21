# Skyburden — Le Poids du Ciel

> *Le monde se disloque. Les montagnes se décrochent de la terre, attirées par une force inconnue. Les survivants ont tout oublié. Quelqu'un, quelque part, sait la vérité.*

**Skyburden** est un jeu PC solo d'exploration et de narration dans un monde en ruine, en cours de dislocation physique. Ambiance dystopique, solitude permanente, visuel rétro-3D type début des années 90 (DOOM, Basilisk 2000).

## Statut

**Phase : production du code — Godot 4.x (GDScript), projet dans `game/`.**

Jalon **M1** en cours : Cendreval (ville de départ, white-box) + Ben le glaneur (PNJ, dialogues en JSON français) + ciel dynamique (Mars grandit pendant la boucle de 37 min, flash rouge au crash, monde restauré à chaque boucle, mémoire persistante). Le prototype raycaster Python (zéro dépendance) reste dans le repo comme bac à sable technique.

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
├── scenario/
│   └── synopsis.md    # Synopsis en trois actes (brouillon)
└── cartes/
    └── strate_0.png   # Carte canonique de la Strate 0 (la terre ferme)

game/                  # projet Godot 4 (moteur de production)
├── autoload/          # GameState, LoopManager, WorldState, MemoryStore
├── scripts/           # player, sky_manager, npc
├── scenes/            # main, zones/cendreval, npc/ben, ui/hud
├── data/dialogues/    # dialogues FR (JSON)
└── assets/ + addons/

skyburden/             # prototype raycaster Python (stdlib uniquement)
main.py                # point d'entrée du prototype
maps/                  # cartes du prototype (texte)
tests/                 # tests du prototype (unittest)
```

## Lancer le jeu (Godot)

Ouvrir `game/` dans **Godot 4.x** puis `F5`. Boucle de test : 5 min (`LoopManager.USE_TEST_DURATION`), boucle canonique : 37 min. Voir `game/README.md`.

## Lancer le prototype Python

```bash
python3 main.py --out out/frame.png            # une image à la position de départ
python3 main.py --demo out/demo                 # une séquence de déplacements
python3 -m unittest discover -s tests           # tests
```

## Nom

- **Titre** : *Skyburden*
- **Sous-titre français** : *Le Poids du Ciel*
- **Nom technique / repo** : `skyburden`
