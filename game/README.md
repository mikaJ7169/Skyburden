# Skyburden — projet Godot 4

## Lancer

Ouvrir le dossier `game/` dans **Godot 4.x** (4.2+), puis lancer la scène principale (`F5`).
Le jeu démarre en **plein écran** (1920×1080 fenêtré si besoin) ; **F11** bascule plein écran / fenêtré.
Rendu rétro-3D : résolution interne **640×400** upscalée plein écran, textures 64 px en **nearest**, fog dense.

- La boucle dure **37 minutes** (constante `LoopManager.LOOP_DURATION_MINUTES`). Mode test 5 min : remettre `USE_TEST_DURATION = true`.

## Contrôles

- **ZQSD ou WASD + souris** — se déplacer / regarder
- **F** — parler / ramasser / avancer dans les dialogues (invite « F — … » quand on vise un objet)
- **F11** — plein écran on/off
- **Tab** — inventaire (objets ramassés, persistants entre boucles via la mémoire)
- **Échap** — menu pause (onglet **Paramètres** : changer toutes les touches, sauvegardé dans `user://keybinds.cfg`)

## Jalons en cours

- **M0/M1** : réveil dans le **sous-sol** (fondu depuis le noir, lampe à huile à ramasser avec `F`), rampe remontant jusqu'à **Cendreval** + **Ben le glaneur** (visible, étiquette 3D, ouverture dans l'auberge) + ciel dynamique.
- **Village en ruine pillé** : textures procédurales 128 px (pierre à blocs + fissures + mousse, brique, pavés, bois, tuiles, métal), maisons éventrées (murs troués, toits tombés/penchés, cheminées), tonneaux, caisses, clôtures, charrette cassée, tas de foin, planches et livres éparpillés, gravats.
- **Ciel à deux planètes voilées de brume** (alpha 0.85, toujours visibles) : la planète de l'IA (sombre, texture façon Étoile de la Mort : quadrillage + superlaser + tranchée équatoriale) apparaît d'abord **plus grosse que Mars**, puis **Mars orange à cratères** grandit et la dépasse ; flash rouge au crash.
- **Lumières** : lampadaires néon vert pâle avec scintillement (OmniLight3D), fenêtres chaudes dans quelques maisons, lampe à huile portée, vignette en post-processing.
- **Débris flottants** (limite d'arrachement + morceaux en ville) qui dérivent **très légèrement** vers la planète de l'IA au fil de la boucle.
- **Objets interactifs animés** : lampe à huile, radio morte, livre (crime selon l'Église), conserves — animation de ramassage (lévitation + rotation + rétrécissement), drapeaux de mémoire persistants entre boucles, listés dans l'inventaire (Tab).
- Solides en `StaticBody3D` explicites (collision garantie), limite d'arrachement rouge émissive.

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
