# Skyburden — projet Godot 4

## Lancer

Ouvrir le dossier `game/` dans **Godot 4.x** (4.2+), puis lancer la scène principale (`F5`).

- Rendu rétro-3D : résolution interne **640×400**, upscalée plein écran (fenêtre 1280×800 par défaut), textures 64 px en **nearest**, fog dense, éclairage flat (soleil sans ombres + ambiante).
- Mode test : la boucle dure **5 minutes** (`LoopManager.USE_TEST_DURATION = true`). Mettre `false` pour la boucle canonique de **37 minutes**.

## Contrôles

- **WASD + souris** — se déplacer / regarder
- **E** — parler / ramasser / avancer dans les dialogues
- **Échap** — libérer la souris

## Jalons en cours

- **M0/M1** : réveil dans le **sous-sol** (fondu depuis le noir, lampe à huile à ramasser avec `E`), rampe remontant jusqu'à **Cendreval** (ville de départ) + **Ben le glaneur** + ciel dynamique (Mars grandit pendant la boucle, flash rouge au crash, monde restauré à chaque boucle, mémoire persistante).
- Solides en `StaticBody3D` explicites (collision garantie), textures procédurales 64 px, lampadaires néon, piliers, portes sans issue, gravats, débris flottants, limite d'arrachement rouge.

## Structure

```
game/
├── project.godot
├── autoload/        # GameState, LoopManager (boucle 37 min), WorldState (snapshot), MemoryStore (drapeaux persistants)
├── scripts/         # player, sky_manager, npc, oil_lamp, builder, textures
├── scenes/
│   ├── main.tscn    # assemble environnement, lumière, zones, PNJ, joueur, HUD
│   ├── zones/       # sous_sol.tscn (départ) + cendreval.tscn (ville de départ)
│   ├── npc/         # ben.tscn
│   └── ui/          # hud.tscn — compte à rebours, fondu noir, dialogues
├── data/dialogues/  # dialogues en français (JSON), jamais dans le code
├── assets/          # models (.glb low-poly), textures 64-128px, audio
└── addons/          # plugins (shader rétro, dialogues)
```
