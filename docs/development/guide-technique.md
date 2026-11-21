# Guide technique de production — Skyburden

> Document de référence pour le développement. Contient la manière dont le jeu est créé : moteur, architecture, graphismes, audio, jalons.

## 1. Moteur et outils

- **Moteur : Godot 4.x** (décision validée — développement après la phase d'écriture).
- **Langage : GDScript** (prototypage rapide) ; modules critiques (loop manager, streaming) peuvent passer en C# ou GDExtension si besoin de performance.
- **Versionner le projet Godot dans ce repo** (dossier `game/`) : `.gitignore` standard Godot (`.godot/`).

## 2. Architecture du jeu

### Le cœur : la boucle temporelle
- **`LoopManager`** (autoload/singleton) :
  - Chronomètre de boucle (**37 minutes** de temps de jeu, chiffre ajustable en constante).
  - À l'échéance : **remonte le monde 30 minutes avant le crash de Mars** → réinitialise toutes les entités à leur état de départ ; ramène le joueur **au sous-sol** (point de départ).
- **Deux échelles de temps distinctes** :
  - **Échelle A (monde)** : tout ce qui se réinitialise à chaque boucle (positions des PNJ, objets ramassés, portes, quêtes du monde).
  - **Échelle B (mémoire — la machine quantique)** : tout ce qui persiste à travers les boucles (**connaissance du joueur** : infos apprises, zones visitées, notes de la note). C'est le seul système de progression — comme un « ship log » d'Outer Wilds.
- **`WorldState`** : sérialisation/désérialisation de l'état de toutes les entités du monde (snapshot pris au démarrage de la boucle, restauré à la réinitialisation).
- **PNJ** : comportements **déterministes** (scripts planifiés sur la timeline de la boucle) pour garantir qu'ils se répètent à l'identique. **Drapeaux de tâches** : si le joueur accomplit une tâche (portée dans l'échelle B), le PNJ change de réaction/branche de dialogue.

### Le monde
- **Toutes les zones accessibles dès le début** — pas de murs arbitraires : la seule barrière est la connaissance (comment survivre, comment monter, où aller).
- Zones : Sous-sol · Cendreval · Strate 0 (carte canonique — 6 populations, montagne des voleuses, 4 ruines, 2 forêts, 2 clairières) · Strates moyennes (Amarreurs, ermites, villages arrachés) · Strates supérieures (L'Horloger, quartier caché de Sésame) · Débris spatial (fin).
- Découpage en **scènes Godot** par zone, chargées en streaming (`change_scene_to_packed` ou subdivision manuelle).

### Le ciel
- **Skybox dynamique** : Mars grandit progressivement pendant la boucle jusqu'au crash (sprite/mesh scale + light + teinte du ciel qui vire). Le crash est un événement visuel/sonore court juste avant la réinitialisation.

## 3. Graphismes — style rétro-3D (début des années 90)

Objectif : rendu type **DOOM / Basilisk 2000**, **espaces liminaux** (géométrie distordue, lumière fluorescente pâle, perspectives longues, vide).

- **Résolution interne basse** (ex. 640×400) upscalée en plein écran avec pixel-perfect (filtre nearest) → pixellisation naturelle.
- **Caméra fps classique** (renders 3D low-poly, pas de sprites billboard obligatoires).
- **Modèles 3D very low-poly** (style PS1/N64) ; textures basse résolution **64–128 px**, filtrage **nearest** (pas de mipmaps lissés), pas de PBR.
- **Effet rétro-3D type PS1** (si choisi) : *vertex snapping* + *affine texture mapping* via shader (plugin/shader existant à adapter) ; optionnel : jitter léger des vertex.
- **Éclairage** : le plus **flat** possible — lumière quasi constante, pas d'ombres dynamiques coûteuses ; halos *emission* simples pour les néons/fluorescents ; **brouillard** (fog) dense pour les perspectives liminales et les fonds invisibles.
- **Palette désaturée** : gris, blancs cassés, verts pâles, bruns ; le rouge réservé à la limite d'arrachement et à Mars.
- **Géométrie distordue** : bâtiments avec pièces en trop, portes qui ne mènent nulle part, proportions fausses (construits exprès dans les maquettes).
- **Post-processing minimal** : dithérage léger optionnel, vignette, léger grain. Pas de bloom moderne agressif.

## 4. Audio

- **Ambiances** plutôt que musique : vent, silence, néons qui bourdonnent, pas.
- Musique diégétique rare (phonographe dans le Val-Tranquille, etc.) + une seule pièce musicale pour l'écran noir (première fin).
- Sons du crash de Mars à chaque fin de boucle.

## 5. Structure de contenu / pipeline

```
game/
  addons/            # plugins (rétro shader, dialogues)
  assets/
    models/          # low-poly (.glb)
    textures/        # 64-128px
    audio/
  autoload/          # LoopManager, WorldState, MemoryStore, GameState
  scenes/
    zones/           # sous_sol, cendreval, val_tranquille, lazaret, ...
    npc/             # scènes de PNJ avec leur timeline de boucle
    ui/
  scripts/
```

- **Dialogues** : système simple de files textes (CSV/JSON) — tout le contenu des dialogues est dans des fichiers de données, pas dans le code.
- **Textes / indices** : tous les dialogues et documents sont en **français**.

## 6. Jalons de production

- **M0 — Prototype de boucle** : un sous-sol white-box, réveil, sortie dans une petite zone vide, timer 37 min (réduit à 5 min pour tests), réinitialisation, mémoire qui persiste, Mars dans le ciel. *C'est le jalon qui valide la faisabilité.*
- **M1 — Cendreval + Ben** : ville en ruines white-box + PNJ Ben (dialogues sans timeline complexe), bases de survie (faim/soif/filtrage), lampe à huile.
- **M2 — La boucle complète** : PNJ qui se répètent (timeline déterministe), drapeaux de tâches, écran noir (première fin) → retour de L'Horloger.
- **M3 — Strate 0 peuplée** : Val-Tranquille (5), Lazaret (4 + quête des herbes), voleuses (3), ruines et forêts.
- **M4 — Verticalité** : strates moyennes (Amarreurs), strates supérieures (L'Horloger, Sésame), montée physique (comment on grimpe — à designer).
- **M5 — Les fins** : capsule, note, sous-sol arraché, combinaison spatiale, débris spatial.
- **M6 — Direction artistique complète** : remplacement du white-box par les assets rétro-3D, lumières liminales, fog, audio.
- **M7 — Équilibrage & polish** : durée de boucle, rythme des 37 minutes, densité des indices.

## 7. Risques/points ouverts à trancher

- Le moteur graphique exact du look rétro (shader PS1 vs restrictions de rendu pures).
- Comment le joueur **monte** d'une strate à l'autre physiquement (grimpée ? échelles d'Amarreurs ? ascension de fragments ?).
- Le contenu de la boucle qui « tient » en 37 minutes : routing type Outer Wilds à designer finement.
- Cohérence à clarifier (scénario) : le sous-sol, à la fois point de départ de chaque boucle et « arraché, caché dans les strates » dans la deuxième fin.
