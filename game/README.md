# Skyburden — projet Godot 4

## Lancer

Ouvrir le dossier `game/` dans **Godot 4.x** (4.2+), puis lancer la scène principale (`F5`).

- Rendu rétro-3D : résolution interne **640×400**, upscalée plein écran (fenêtre 1280×800 par défaut), textures en **nearest**, fog dense, matériaux unshaded (éclairage flat).
- Mode test : la boucle dure **5 minutes** (`LoopManager.USE_TEST_DURATION = true`). Mettre `false` pour la boucle canonique de **37 minutes**.

## Contrôles

- **Z/Q/S/D ou flèches** — se déplacer (WASD : ZQSD/AZERTY non géré, utiliser WASD)
- **Souris** — regarder
- **E** — parler / interagir / avancer dans les dialogues
- **Échap** — libérer la souris

## Jalons en cours

- **M1** : Cendreval (ville de départ, white-box) + Ben le glaneur + ciel dynamique (Mars grandit pendant la boucle, flash rouge au crash, monde restauré).

## Structure

```
game/
├── project.godot
├── autoload/        # GameState, LoopManager (boucle 37 min), WorldState (snapshot), MemoryStore (drapeaux persistants)
├── scripts/         # player.gd, sky_manager.gd, npc.gd
├── scenes/
│   ├── main.tscn    # assemble environnement, lumière, zone, PNJ, joueur, HUD
│   ├── zones/       # cendreval.tscn — ville de départ
│   ├── npc/         # ben.tscn
│   └── ui/          # hud.tscn — compte à rebours + dialogues
├── data/dialogues/  # dialogues en français (JSON), jamais dans le code
├── assets/          # models (.glb low-poly), textures 64-128px, audio
└── addons/          # plugins (shader rétro, dialogues)
```
