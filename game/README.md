# Skyburden — projet Godot 4

## Lancer

Ouvrir le dossier `game/` dans **Godot 4.x** (4.2+), puis lancer la scène principale (`F5`).
Le jeu démarre en **plein écran** (1920×1080 fenêtré si besoin) ; **F11** bascule plein écran / fenêtré.
Rendu rétro-3D : résolution interne **640×400** upscalée plein écran, textures 64 px en **nearest**, fog dense.

- Mode test : la boucle dure **5 minutes** (`LoopManager.USE_TEST_DURATION = true`). Mettre `false` pour la boucle canonique de **37 minutes**.

## Contrôles

- **ZQSD ou WASD + souris** — se déplacer / regarder
- **F** — parler / ramasser / avancer dans les dialogues (invite « F — … » quand on vise un objet)
- **F11** — plein écran on/off
- **Échap** — menu pause (onglet **Paramètres** : changer toutes les touches, sauvegardé dans `user://keybinds.cfg`)

## Jalons en cours

- **M0/M1** : réveil dans le **sous-sol** (fondu depuis le noir, lampe à huile à ramasser avec `F`), rampe remontant jusqu'à **Cendreval** + **Ben le glaneur** (visible, étiquette 3D, ouverture dans l'auberge) + ciel dynamique.
- **Ciel à deux planètes** : la planète construite par l'IA apparaît d'abord **plus grosse que Mars**, puis Mars grandit pendant la boucle et la dépasse ; au crash de fin de boucle, flash rouge + réinitialisation.
- **Débris flottants** (limite d'arrachement + morceaux en ville) qui **dérivent vers la planète de l'IA** à l'horizon au fil de la boucle.
- **Objets interactifs animés** : lampe à huile, radio morte, livre (crime selon l'Église), conserves — animation de ramassage (lévitation + rotation + rétrécissement), drapeaux de mémoire persistants entre boucles.
- Solides en `StaticBody3D` explicites (collision garantie), textures procédurales 64 px, lampadaires néon, piliers, portes sans issue, gravats, limite d'arrachement rouge.

## Structure

```
game/
├── project.godot
├── autoload/        # Keybinds (touches remappables), GameState, LoopManager (boucle 37 min), WorldState, MemoryStore
├── scripts/         # player, sky_manager, npc, interactable, relic, oil_lamp, builder, textures
├── scenes/
│   ├── main.tscn    # assemble environnement, lumière, zones, PNJ, joueur, HUD
│   ├── zones/       # sous_sol.tscn (départ) + cendreval.tscn (ville de départ)
│   ├── npc/         # ben.tscn
│   └── ui/          # hud.tscn (compte à rebours, fondu, invite, dialogues) + pause_menu.tscn (onglet Paramètres)
├── data/dialogues/  # dialogues en français (JSON), jamais dans le code
├── assets/          # models (.glb low-poly), textures 64-128px, audio
└── addons/          # plugins (shader rétro, dialogues)
```
