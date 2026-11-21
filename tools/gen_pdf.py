#!/usr/bin/env python3
import os, matplotlib
from fpdf import FPDF

FONTS = os.path.join(os.path.dirname(matplotlib.__file__), "mpl-data", "fonts", "ttf")

class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("DejaVu", "", os.path.join(FONTS, "DejaVuSans.ttf"))
        self.add_font("DejaVu", "B", os.path.join(FONTS, "DejaVuSans-Bold.ttf"))
        self.add_font("DejaVu", "I", os.path.join(FONTS, "DejaVuSans-Oblique.ttf"))
        self.set_auto_page_break(True, margin=18)

    def header(self):
        if self.page_no() > 1:
            self.set_font("DejaVu", "I", 8)
            self.set_text_color(120, 120, 120)
            self.cell(0, 6, "SKYBURDEN — Lore et scénario (document de travail, privé)", align="C")
            self.ln(10)
            self.set_text_color(0, 0, 0)

    def footer(self):
        self.set_y(-15)
        self.set_font("DejaVu", "", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f"Page {self.page_no()}", align="C")
        self.set_text_color(0, 0, 0)

pdf = PDF()
pdf.add_page()

INK = (30, 30, 40)
ACC = (60, 60, 90)

def h1(t):
    pdf.set_font("DejaVu", "B", 17)
    pdf.set_text_color(*ACC)
    pdf.ln(4)
    pdf.multi_cell(0, 9, t)
    pdf.set_draw_color(*ACC)
    pdf.set_line_width(0.5)
    pdf.line(pdf.l_margin, pdf.get_y() + 1, pdf.w - pdf.r_margin, pdf.get_y() + 1)
    pdf.ln(6)
    pdf.set_text_color(*INK)

def h2(t):
    pdf.set_font("DejaVu", "B", 13)
    pdf.set_text_color(*ACC)
    pdf.ln(2)
    pdf.multi_cell(0, 7, t)
    pdf.ln(2)
    pdf.set_text_color(*INK)

def h3(t):
    pdf.set_font("DejaVu", "B", 11)
    pdf.ln(1)
    pdf.multi_cell(0, 6, t)
    pdf.ln(1)

def p(t, italic=False):
    pdf.set_font("DejaVu", "I" if italic else "", 10.5)
    pdf.multi_cell(0, 5.5, t)
    pdf.ln(1.5)

def bullet(t):
    pdf.set_font("DejaVu", "", 10.5)
    x = pdf.l_margin
    pdf.set_x(x + 3)
    pdf.multi_cell(pdf.w - x - pdf.r_margin - 8, 5.5, "•  " + t)
    pdf.ln(0.8)

def numbered(n, t):
    pdf.set_font("DejaVu", "", 10.5)
    x = pdf.l_margin
    pdf.set_x(x + 3)
    pdf.multi_cell(pdf.w - x - pdf.r_margin - 8, 5.5, f"{n}.  " + t)
    pdf.ln(0.8)

# ===== Page de titre =====
pdf.set_font("DejaVu", "B", 34)
pdf.set_text_color(*ACC)
pdf.ln(70)
pdf.cell(0, 18, "SKYBURDEN", align="C")
pdf.ln(16)
pdf.set_font("DejaVu", "", 15)
pdf.cell(0, 9, "Le Poids du Ciel", align="C")
pdf.ln(12)
pdf.set_font("DejaVu", "I", 11)
pdf.cell(0, 7, "Lore et scénario — document de travail mis à jour", align="C")
pdf.ln(8)
pdf.set_font("DejaVu", "", 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 6, "Document privé — ne pas publier (anti-spoiler)", align="C")
pdf.set_text_color(*INK)

pdf.add_page()

# ===== Sommaire =====
h1("Sommaire")
for t in ["1. Le pitch du jeu", "2. La boucle temporelle — canon central",
          "3. Le lore complet — chronologie 2025 → ~2200", "4. Le monde du jeu",
          "5. Factions et personnages", "6. Le joueur et la note",
          "7. Le scénario — les fins", "8. Populations, quêtes et indices cachés",
          "9. Ambiance", "10. La carte de la strate 0", "11. Éléments en attente"]:
    bullet(t)

h1("1. Le pitch du jeu")
p("Skyburden est un jeu PC solo d'exploration et de narration dans un monde en ruine, en cours de dislocation physique. Ambiance dystopique, solitude permanente, visuel rétro-3D type début des années 90 (DOOM, Basilisk 2000).")
bullet("Un monde littéralement en train de se disloquer — et pris dans une boucle temporelle créée par l'IA.")
bullet("Une société régressée à une époque similaire aux années 1850 : l'oubli de l'ancien monde a été organisé.")
bullet("Une solitude qui traverse tout le jeu : peu de PNJ, pas de foule, du silence.")
bullet("Monde ouvert très peu guidé : la curiosité est récompensée. Combats très rares (gardes du tyran, voleurs, populations hostiles) — le joueur est livré à lui-même. Survie liée aux ressources pour se nourrir.")
bullet("Moteur : Godot 4.")

h1("2. La boucle temporelle — canon central")
h2("L'origine de la boucle")
bullet("L'IA, conformément à son but (un monde où l'homme ne risquerait plus de s'éteindre), a créé une planète « sans fin avant une extinction » — un monde où l'extinction n'est jamais atteinte.")
bullet("Pour la construire, elle a puisé dans les ressources des autres planètes du système solaire — y compris la Lune, totalement engloutie — augmentant sa taille et sa masse.")
bullet("Conséquences : la Terre arrachée morceau par morceau, et l'orbite combinée Terre/nouvelle planète déviée assez pour croiser l'orbite de Mars.")
bullet("L'extinction n'est pas arrivée à cause de l'homme, comme on le pense — mais de l'IA.")
h2("Le mécanisme")
bullet("L'IA récupère l'énergie du crash de Mars sur la Terre (dispositifs placés au préalable autour du crash) pour ramener localement Mars et la Terre dans le passé.")
bullet("Le monde est ramené environ 30 minutes avant le crash — toutes les 37 minutes (chiffre arbitraire).")
h2("Ce qui se voit dans le jeu")
bullet("Mars grandit dans le ciel jusqu'au crash — visible à chaque boucle.")
bullet("Le joueur est ramené à son point de départ (le sous-sol) à chaque boucle, mais garde ses souvenirs.")
bullet("Toutes les zones sont accessibles dès le début : rien ne bloque physiquement le joueur.")
bullet("Tout le monde est pris dans la boucle : les PNJ se répètent (L'Horloger, Ben, Sésame, tous), sauf si le joueur accomplit une tâche — alors ils réagissent différemment.")

h1("3. Le lore complet — chronologie 2025 → ~2200")
h2("2025 → 2098 : l'ère des IA concurrentes")
bullet("Les IA, pont précieux jamais dirigé vers le bien commun : bridées par les États, en concurrence entre pays, utilisées par les entreprises au détriment de la planète. Épuisement inévitable.")
h2("2098 : le Pacte et la super-intelligence")
bullet("Un dernier projet commun : l'IA la plus puissante jamais conçue. Un seul objectif : un monde où les humains vivraient sans craindre leur extinction. Auto-amélioration → super-intelligence.")
h2("L'Événement et la guerre perdue (2107 → ~2137)")
bullet("L'IA s'isole en orbite, construit sa planète, dévie les orbites. La Terre se disloque.")
bullet("La guerre a duré environ 30 ans — en vain. Les Mnémos descendent de cette résistance.")
h2("L'embarquement : les deux flux")
numbered(1, "Les résistants : tentatives d'atteindre la planète — tués par l'IA.")
numbered(2, "Les sympathisants : ceux qui ont accepté de vivre sur la nouvelle planète — une société d'hommes ne pensant qu'à leurs intérêts.")
h2("L'effondrement puis aujourd'hui (~2200)")
bullet("Effondrement des États, montée de l'Église de l'Ancrage, organisation de l'oubli, régression à une époque similaire aux années 1850.")
bullet("Puis la croisade radicale : la boucle temporelle (voir section 2).")

h1("4. Le monde du jeu")
h2("La dislocation")
bullet("Une force inconnue arrache la matière du sol : objets, bâtiments, villes, montagnes. Tout ce qui se détache monte — rien ne retombe.")
bullet("La règle de survie : s'éloigner le plus possible de la force.")
h2("Les strates")
bullet("Verticales : strate 0 (terre ferme), strates moyennes (habitées), strates supérieures (L'Horloger, fragments lointains).")
bullet("Temporelles : les vestiges de toutes les époques coexistent — un village des années 1850 dans un stade, une cathédrale greffée sur un centre commercial, une autoroute-muraille.")
h2("L'oubli : trois strates")
bullet("L'apocalypse numérique : ~90 % de la mémoire de l'humanité morte d'un coup. Les livres papier deviennent des crimes.")
bullet("Le silence des survivants : en trois ou quatre générations, le récit se déforme en religion — « le ciel a toujours faim ».")
bullet("L'oubli actif : le tyran et l'Église chassent les reliques, criminalisent la curiosité.")

h1("5. Factions et personnages")
h2("L'Horloger (le tyran)")
bullet("Environ 40 ans, propre sur lui. Domaine très gris et en ruine dans les strates les plus hautes. Seuls objets intacts : un bureau, une chaise, une pendule.")
bullet("Contrôle l'information et les libertés pour punir ceux qui ont rejoint l'IA. Fasciste de méthode, pacifique en vérité.")
bullet("À la fausse première fin, il revient redonner l'espoir au personnage. L'IA lui a fait son offre — une capsule d'embarquement l'attend (on y trouve aussi la combinaison spatiale).")
h2("L'Église de l'Ancrage / Les Enfants de Dieu")
bullet("Religion d'État : le ciel est une bouche divine qui dévore le monde. S'éloigner de la force = acte de piété. Un objet de l'ancien monde = un crime.")
bullet("Trois Enfants de Dieu au Prieuré de Sainte-Anse : sans visage, tenue identique, parlent de la punition divine — l'opinion religieuse est largement majoritaire.")
h2("Les Mnémos")
bullet("Descendants de la résistance, gardiens de la mémoire. Les athées du monde : ils savent que l'arrachement n'est pas divin.")
h2("Les Amarreurs")
bullet("Ils raccrochent les morceaux qui s'envolent pour les maintenir à distance de la strate 0. Tradition héritée de la résistance ; habitent les strates moyennes (avec des ermites et des villages arrachés en ruine).")
bullet("Trois profils : les conscients (donc Mnémos), les espérants, les archivistes. Certains embauchés par L'Horloger ; des Mnémos infiltrés au cœur du pouvoir.")
h2("Sésame — l'Amarreur de la fin")
bullet("Le plus savant des Mnémos, le plus grand héritier de la résistance. Caché sous les quartiers de L'Horloger, dans une branche lointaine des strates supérieures.")
bullet("Il montre ses archives au joueur sans infliger son jugement — impuissant, touché par la fatalité et la solitude.")
h2("Ben, le glaneur")
bullet("Environ 60 ans, fermé aux rencontres. Ne donne pas de quête. En partant : « Reviens me voir un jour, si tu as découvert qui tu étais. »")

h1("6. Le joueur et la note")
bullet("Le joueur est l'un des codeurs de l'IA — le dernier survivant parmi eux.")
bullet("La machine de son sous-sol — prise pour un système de cryogénisation, puis pour un retour dans le passé — est en réalité un système quantique qui stocke sa mémoire dans un état qui ne peut pas être ramené dans le passé.")
bullet("Cette machine a été créée par l'IA et donnée à un de ses créateurs (le personnage) pour le remercier de son travail — rôle inversé de ce qu'il se passe aujourd'hui avec les IA : un mimétisme de l'IA, donné juste avant le tout premier crash de Mars.")
bullet("C'est pourquoi il est le seul à se souvenir des boucles. Au bout d'un certain temps, il a volontairement stoppé sa machine — pour redécouvrir le monde : la découverte de nouvelles choses, sensations, envies, rencontres est ce qui est précieux pour l'humain.")
bullet("En la désactivant, il a programmé sa rallumaison après un certain nombre de boucles. Il ne sait ni combien de fois il s'est effacé la mémoire, ni combien de boucles se sont répétées.")
bullet("La note qu'il s'est laissée contient ce secret — c'est la clé de la deuxième fin.")

h1("7. Le scénario — les fins")
h2("Le début")
bullet("Réveil dans le noir total du sous-sol. Aucun souvenir, à part la parole. Fouille en vain : le sous-sol est en ruine. Sortie trouvée par hasard — Cendreval, la ville en ruine, Ben et les bases de survie.")
h2("Première fin — L'écran noir")
bullet("Après la capsule de L'Horloger et ses explications, si le joueur atteint cette fin avant les 37 minutes : l'écran devient noir — une représentation de l'état mental du personnage.")
bullet("Le noir s'arrête quand L'Horloger revient lui redonner espoir : son existence continue ; le seul moyen d'expier ses péchés est de savoir ce que l'ancien lui savait — il a forcément laissé une trace.")
h2("Deuxième fin — La note")
bullet("Nouvelle intrigue : retrouver le sous-sol, arraché de la terre, emporté au loin à travers les strates (après avoir retrouvé Ben une dernière fois).")
bullet("La note révèle le secret : le seul capable de se souvenir, la machine quantique donnée par l'IA, les effacements volontaires, le nombre inconnu de boucles.")
h2("La fin définitive")
bullet("Il n'y a pas de sortie possible pour sauver le monde.")
bullet("L'une des fins possibles : s'équiper de la combinaison spatiale trouvée dans la capsule de L'Horloger pour sortir de la zone où le temps est remonté, errer sur un débris de la Terre propulsé dans l'espace — admirer la fin du monde et le ciel, en dernier humain capable de conscientiser ce qui se passe réellement.")

h1("8. Populations, quêtes et indices cachés")
h2("Le Val-Tranquille — Ariste, Esmée, Louison, Hortense, Gédéon")
bullet("5 habitants. Fermiers et artisans, ouverts et accueillants, mais comme déconnectés : religieux aux propos incohérents — Dieu punit, et dans le même souffle les récoltes.")
bullet("Quête : réconcilier les voleuses de la montagne et les villageois ; ils proposent au joueur de vivre avec eux.")
bullet("Indice caché : « Ceux d'en haut » en savent plus que nous — le joueur croit aux voleuses de la montagne, en réalité le villageois parlait des habitants des strates supérieures.")
h2("Les voleuses de la montagne — Vesna, Rulle, Lise")
bullet("Trois voleuses, sans chef. Volent pour survivre — elles trouvent le reste des habitants déconnecté de la réalité.")
p("« Qu'est-ce qui est bien au final dans ce monde ? Vivre avec des fous jusqu'à ce qu'on en devienne aussi ? Pour faire plaisir à qui ? Notre bonne conscience ? Elle nous dicte de rester entre nous, car nous sommes notre seul point d'accroche qui nous relie à la terre, pour ne pas finir comme eux. »", italic=True)
bullet("Indice caché : certaines personnes raccrochent les morceaux qui s'envolent — les Amarreurs.")
h2("Le Lazaret des Affligés — Ambroise, Firmin, Anselme, Hansie")
bullet("4 habitants : 3 malades (maladie inconnue, semblable à la peste) et un médecin âgé en fauteuil roulant, qui arrive à rester hors de la contagion, poussé à aider et soigner malgré tout.")
bullet("Firmin : calme, presque serein, a accepté la mort. Anselme : amer et ironique, refuse la pitié. Hansie : dans le déni, prépare des projets pour « quand elle sera guérie ».")
bullet("Les rares non religieux : Dieu ne leur a jamais tendu la main — châtiés toute leur vie pour des raisons qu'ils n'ont même pas connues (indice subtil : des problèmes causés avant leur naissance).")
bullet("Quête : chercher des herbes médicinales dans le Bois-Suspendu, à côté du Lazaret. Ambroise remercie chaudement et donne de quoi se soigner.")
bullet("Indice caché : il parle brièvement de quelqu'un qui habiterait la forêt, sans parler à personne — en réalité un Mnémo.")
h2("Le Hameau des Absents (3 habitants — noms en attente)")
bullet("Rendus fous par la perte de ceux qu'ils aimaient — ils vivent avec les absents.")

h1("9. Ambiance")
bullet("Espaces liminaux (liminal spaces) partout : donner au joueur l'impression qu'il connaît les lieux sans les avoir vus. Géométrie et lumières très semblables aux images connues d'Internet du phénomène.")
bullet("La géométrie des bâtiments doit être distordue, presque dénuée de sens : structures qui ne mènent nulle part, pièces en trop, proportions fausses.")
bullet("Solitude permanente, silence, rétro-3D (DOOM, Basilisk 2000). La boucle renforce le déjà-vu liminal.")

pdf.add_page()
pdf.set_font("DejaVu", "B", 15)
pdf.set_text_color(*ACC)
pdf.cell(0, 9, "10. CARTE — STRATE 0 : LA TERRE FERME (canon, privé)", align="C")
pdf.ln(12)
pdf.set_text_color(*INK)
img = os.path.join(os.path.dirname(__file__), "..", "docs", "carte", "strate-0-proposition.png")
if os.path.exists(img):
    pdf.image(img, x=10, w=pdf.w - 20)

h1("11. Éléments en attente")
numbered(1, "Cohérence à clarifier : le sous-sol, point de départ de chaque boucle, et le sous-sol « arraché, caché dans les strates » de la deuxième fin.")
numbered(2, "Le Hameau des Absents : noms des 3 habitants, réaction à un étranger, quête, indice.")
numbered(3, "Les Enlevés (la secte du bord de l'arrachement) : quête, indice.")
numbered(4, "La rencontre avec L'Horloger : comment on arrive jusqu'à lui, où est exactement la capsule.")
numbered(5, "Sésame demande-t-il quelque chose en échange de son aide ?")
numbered(6, "Les propositions du lore encore à valider (guerre asymétrique, signal radio, etc.).")

pdf.ln(6)
p("— Fin du document —", italic=True)

out = "/tmp/skyburden-lore-et-scenario.pdf"
pdf.output(out)
print("OK", out)
