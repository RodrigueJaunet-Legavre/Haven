import Foundation

enum JourneyAppCheck {
    case blockerActive
    case trustedContact
    case checkInToday
    case emergencyReasonAdded
}

struct JourneyField: Identifiable {
    let id: String
    let label: String
    let placeholder: String
    let minCharacters: Int
}

enum JourneyRequirement {
    case writing([JourneyField])
    case choice(id: String, prompt: String, options: [String])
    case app(JourneyAppCheck)
    case breathing(seconds: Int)
}

struct JourneyDay: Identifiable {
    let number: Int
    let title: String
    let summary: String
    let task: String
    let minutes: Int
    let icon: String
    let requirements: [JourneyRequirement]

    var id: Int { number }
    var isMilestone: Bool { [7, 14, 21, 30].contains(number) }
}

private func field(_ id: String, _ label: String, _ placeholder: String, _ minCharacters: Int = 10) -> JourneyField {
    JourneyField(id: id, label: label, placeholder: placeholder, minCharacters: minCharacters)
}

func journeyWeekNumber(for day: Int) -> Int {
    min((day - 1) / 7 + 1, 4)
}

func journeyWeekTitle(_ week: Int) -> String {
    switch week {
    case 1: return "Poser les bases"
    case 2: return "Comprendre tes déclencheurs"
    case 3: return "Reconstruire tes habitudes"
    default: return "Tenir dans la durée"
    }
}

let journeyDays: [JourneyDay] = [
    JourneyDay(
        number: 1,
        title: "Pourquoi maintenant ?",
        summary: "Ta motivation est ton point d'appui les jours difficiles. La formuler noir sur blanc la rend plus solide.",
        task: "Écris en une phrase ce que le jeu t'a coûté (argent, temps, relations, sérénité). Puis ajoute à ta liste Emergency une nouvelle raison de tenir bon, une qui te touche vraiment.",
        minutes: 10,
        icon: "heart.fill",
        requirements: [
            .writing([field("cost", "Ce que le jeu t'a coûté", "Argent, temps, relations, sérénité...", 15)]),
            .app(.emergencyReasonAdded)
        ]
    ),
    JourneyDay(
        number: 2,
        title: "Couper l'accès",
        summary: "Plus il est difficile de jouer, moins l'envie a de chances de gagner. Mettre de la distance fonctionne mieux que la seule volonté.",
        task: "Va dans l'onglet Blocker, autorise le blocage et active le pack essentiel. Ajoute aussi les applications de paris ou de casino que tu as sur ton téléphone.",
        minutes: 10,
        icon: "lock.shield.fill",
        requirements: [.app(.blockerActive)]
    ),
    JourneyDay(
        number: 3,
        title: "Faire le ménage",
        summary: "Chaque notification, chaque appli et chaque email promotionnel est une petite invitation à rejouer.",
        task: "Supprime les applications de jeu, désactive leurs notifications et désabonne-toi de leurs emails et SMS promotionnels. Retire aussi ta carte bancaire enregistrée. Puis décris ce que tu as fait.",
        minutes: 10,
        icon: "trash.fill",
        requirements: [
            .writing([field("cleaned", "Ce que tu as supprimé ou désactivé", "Applications, notifications, emails, carte enregistrée...", 20)])
        ]
    ),
    JourneyDay(
        number: 4,
        title: "Protéger ton argent",
        summary: "Quand l'envie arrive, tu as moins de contrôle. Il vaut mieux limiter à l'avance ce que tu peux dépenser à ce moment-là.",
        task: "Mets en place une mesure concrète pour limiter l'argent accessible quand l'envie arrive, puis dis laquelle.",
        minutes: 15,
        icon: "eurosign.circle.fill",
        requirements: [
            .choice(
                id: "measure",
                prompt: "Quelle mesure as-tu mise en place ?",
                options: [
                    "J'ai baissé le plafond de ma carte",
                    "J'ai réduit l'argent disponible sur mon compte courant",
                    "J'ai confié un moyen de paiement à un proche",
                    "Une autre mesure"
                ]
            ),
            .writing([field("detail", "Explique en une phrase ce que tu as fait", "Ce que j'ai changé, et comment...", 20)])
        ]
    ),
    JourneyDay(
        number: 5,
        title: "Te protéger officiellement",
        summary: "En France, tu peux demander à être interdit de jeux : casinos, sites agréés, FDJ et PMU avec compte joueur. C'est une décision sérieuse, elle dure au minimum 3 ans. Elle ne couvre pas les sites non agréés, c'est le rôle du Blocker.",
        task: "Lis les conditions sur interdictiondejeux.anj.fr, puis indique où tu en es. Si c'est trop tôt pour l'interdiction, tu peux déjà demander une auto-exclusion de 24 h à 12 mois auprès des sites où tu as un compte.",
        minutes: 15,
        icon: "hand.raised.fill",
        requirements: [
            .choice(
                id: "ivj",
                prompt: "Où en es-tu ?",
                options: [
                    "J'ai fait ma demande d'interdiction volontaire de jeux",
                    "J'ai demandé une auto-exclusion chez un ou plusieurs opérateurs",
                    "J'ai lu les conditions, je ne la demande pas pour l'instant"
                ]
            ),
            .writing([field("why", "Pourquoi ce choix ?", "Ce qui a pesé dans ta décision...", 15)])
        ]
    ),
    JourneyDay(
        number: 6,
        title: "Ne pas rester seul",
        summary: "L'addiction aime le secret. Une seule personne au courant change déjà beaucoup de choses.",
        task: "Choisis quelqu'un de confiance et renseigne son nom et son numéro ci-dessous. Envoie-lui ensuite un message simple pour lui dire que tu as décidé d'arrêter.",
        minutes: 10,
        icon: "person.2.fill",
        requirements: [.app(.trustedContact)]
    ),
    JourneyDay(
        number: 7,
        title: "Bilan de la première semaine",
        summary: "Tu viens de poser les bases. Regarder en arrière aide à mesurer ce qui a déjà changé.",
        task: "Fais ton check-in du jour, puis note quel moment de la semaine a été le plus difficile. Ce sera ton point de départ pour la semaine 2.",
        minutes: 5,
        icon: "flag.checkered",
        requirements: [
            .app(.checkInToday),
            .writing([field("hardest", "Le moment le plus difficile de ta semaine", "Quand, où, dans quel état...", 15)])
        ]
    ),
    JourneyDay(
        number: 8,
        title: "Tes déclencheurs",
        summary: "Une envie ne vient jamais de nulle part. Elle est souvent liée à une situation, une émotion ou un moment précis.",
        task: "Décris trois situations où l'envie de jouer est apparue (ennui, dispute, jour de paie, match à la télé...). Sois précis : où, quand, avec qui, dans quel état ?",
        minutes: 10,
        icon: "bolt.fill",
        requirements: [
            .writing([
                field("s1", "Situation 1", "Où, quand, avec qui, dans quel état ?", 15),
                field("s2", "Situation 2", "Où, quand, avec qui, dans quel état ?", 15),
                field("s3", "Situation 3", "Où, quand, avec qui, dans quel état ?", 15)
            ])
        ]
    ),
    JourneyDay(
        number: 9,
        title: "Ton moment le plus risqué",
        summary: "Si tu sais quand le risque est le plus grand, tu peux préparer autre chose à ce moment-là au lieu de le subir.",
        task: "Repère le créneau de la semaine le plus dangereux pour toi et prévois dès maintenant une activité de remplacement pour ce créneau.",
        minutes: 10,
        icon: "clock.fill",
        requirements: [
            .writing([
                field("slot", "Ton créneau le plus dangereux", "Le soir, seul, le week-end pendant les matchs...", 10),
                field("plan", "Ce que tu feras à la place", "Une activité précise, avec qui, où...", 15)
            ])
        ]
    ),
    JourneyDay(
        number: 10,
        title: "Le mythe de la revanche",
        summary: "Rejouer pour se refaire est l'un des pièges les plus connus. Les jeux d'argent sont conçus pour que l'opérateur gagne sur la durée, et pour la plupart des jeux chaque partie est indépendante de la précédente.",
        task: "Regarde dans l'onglet Ressources la vidéo de la psychologue Lucia Romo (4 min), puis réponds aux deux questions ci-dessous.",
        minutes: 10,
        icon: "arrow.uturn.backward.circle.fill",
        requirements: [
            .writing([
                field("idea", "Ce que tu retiens de la vidéo", "Une idée qui te parle...", 20),
                field("chase", "La dernière fois où tu as voulu te refaire : ce que ça t'a coûté", "Combien, et comment tu t'es senti ensuite...", 20)
            ])
        ]
    ),
    JourneyDay(
        number: 11,
        title: "Le vrai calcul",
        summary: "Sans te juger : regarder les chiffres en face donne de la force. L'argent que tu gardes peut servir à autre chose.",
        task: "Estime ce que le jeu t'a coûté sur les 3 derniers mois, puis écris ce que tu aurais pu faire avec cette somme.",
        minutes: 10,
        icon: "chart.line.downtrend.xyaxis",
        requirements: [
            .writing([
                field("cost", "Ce que le jeu t'a coûté sur 3 mois (estimation)", "Un montant, même approximatif...", 3),
                field("alt", "Ce que tu aurais pu faire avec cet argent", "Un voyage, une dette, un projet...", 15)
            ])
        ]
    ),
    JourneyDay(
        number: 12,
        title: "Émotions et envies",
        summary: "Beaucoup de joueurs jouent pour fuir une émotion : stress, solitude, colère, ennui. Nommer l'émotion enlève une partie de son pouvoir.",
        task: "Aujourd'hui, à trois moments de la journée, arrête-toi et note ce que tu ressens. Repère si une envie de jouer est liée à cette émotion.",
        minutes: 10,
        icon: "brain.head.profile",
        requirements: [
            .writing([
                field("m1", "Moment 1 : en ce moment, je ressens...", "Une émotion, et pourquoi...", 10),
                field("m2", "Moment 2 : en ce moment, je ressens...", "Une émotion, et pourquoi...", 10),
                field("m3", "Moment 3 : en ce moment, je ressens...", "Une émotion, et pourquoi...", 10)
            ])
        ]
    ),
    JourneyDay(
        number: 13,
        title: "Surfer sur l'envie",
        summary: "Une envie monte, atteint un pic puis retombe, en général en quelques dizaines de minutes, même si tu ne fais rien. Tu peux l'observer sans lui obéir.",
        task: "Lance l'exercice guidé de 5 minutes ci-dessous : inspire 4 secondes, expire 6 secondes, et observe ce que tu ressens dans ton corps. Reste sur cet écran jusqu'à la fin.",
        minutes: 10,
        icon: "wind",
        requirements: [.breathing(seconds: 300)]
    ),
    JourneyDay(
        number: 14,
        title: "Bilan de la deuxième semaine",
        summary: "Tu connais mieux tes déclencheurs. C'est ce qui rend les envies moins imprévisibles.",
        task: "Fais ton check-in, puis choisis le déclencheur qui te concerne le plus et écris comment tu comptes y répondre la semaine prochaine.",
        minutes: 5,
        icon: "flag.checkered",
        requirements: [
            .app(.checkInToday),
            .writing([field("trigger", "Ton déclencheur principal et ta réponse pour la semaine prochaine", "Quand ça arrive, je vais...", 25)])
        ]
    ),
    JourneyDay(
        number: 15,
        title: "Remplir le vide",
        summary: "Le jeu occupait du temps et donnait des sensations fortes. Ce vide doit être rempli, sinon il rappelle vite le jeu.",
        task: "Écris trois activités que tu aimais avant ou que tu aimerais essayer, puis planifie-en une cette semaine, à un jour et une heure précis.",
        minutes: 10,
        icon: "sparkles",
        requirements: [
            .writing([
                field("a1", "Activité 1", "Ce que tu aimais ou aimerais essayer...", 4),
                field("a2", "Activité 2", "Ce que tu aimais ou aimerais essayer...", 4),
                field("a3", "Activité 3", "Ce que tu aimais ou aimerais essayer...", 4),
                field("when", "Celle que tu planifies : quel jour, à quelle heure ?", "Samedi à 15 h, courir avec...", 8)
            ])
        ]
    ),
    JourneyDay(
        number: 16,
        title: "Bouger",
        summary: "L'activité physique libère des endorphines et aide à faire redescendre le stress sans aucun risque.",
        task: "Marche 20 minutes ou fais un peu de sport aujourd'hui, puis note ton humeur avant et après pour voir la différence.",
        minutes: 20,
        icon: "figure.run",
        requirements: [
            .writing([
                field("before", "Ton humeur avant", "Comment tu te sentais...", 8),
                field("after", "Ton humeur après", "Comment tu te sentais...", 8)
            ])
        ]
    ),
    JourneyDay(
        number: 17,
        title: "Ton plan pour les envies",
        summary: "Quand l'envie est là, on réfléchit mal. Un plan écrit à l'avance évite de devoir décider sur le moment.",
        task: "Écris ton plan : si j'ai envie de jouer, alors je fais d'abord une chose, puis une autre, et en dernier je lance le bouton Emergency.",
        minutes: 10,
        icon: "list.clipboard.fill",
        requirements: [
            .writing([
                field("first", "Si j'ai envie de jouer, je fais d'abord...", "Marcher, appeler quelqu'un...", 10),
                field("second", "Puis je fais...", "Une deuxième action...", 10)
            ])
        ]
    ),
    JourneyDay(
        number: 18,
        title: "En parler",
        summary: "Parler de ce que tu traverses, à un proche ou à un professionnel, allège beaucoup la pression.",
        task: "Prends des nouvelles de ta personne de confiance (ou d'un proche) et dis-lui comment ça se passe vraiment, y compris les moments difficiles. Puis raconte comment ça s'est passé.",
        minutes: 10,
        icon: "bubble.left.and.bubble.right.fill",
        requirements: [
            .choice(
                id: "who",
                prompt: "À qui en as-tu parlé ?",
                options: ["Ma personne de confiance", "Un proche ou un ami", "Un professionnel de santé", "Un groupe de parole"]
            ),
            .writing([field("felt", "Comment ça s'est passé ?", "Ce que tu as dit, ce que tu as ressenti...", 20)])
        ]
    ),
    JourneyDay(
        number: 19,
        title: "Ton argent, ton projet",
        summary: "Voir ce que devient l'argent gardé rend l'effort concret et donne une raison de plus de tenir.",
        task: "Choisis un projet ou une récompense qui compte pour toi, et mets de côté chaque semaine, dans un compte ou une enveloppe séparée, le montant que tu dépensais avant.",
        minutes: 10,
        icon: "banknote.fill",
        requirements: [
            .writing([
                field("project", "Ton projet ou ta récompense", "Ce que tu veux t'offrir...", 8),
                field("amount", "Le montant mis de côté chaque semaine", "Par exemple 30 €", 2)
            ])
        ]
    ),
    JourneyDay(
        number: 20,
        title: "Écarter les tentations",
        summary: "Publicités, pronostics et notifications entretiennent l'envie, surtout autour des grands matchs.",
        task: "Désabonne-toi des comptes de pronostics sur les réseaux, coupe les notifications des applications de sport qui parlent de cotes, et repère le prochain grand match pour prévoir autre chose.",
        minutes: 10,
        icon: "eye.slash.fill",
        requirements: [
            .writing([
                field("done", "Ce que tu as désabonné ou désactivé", "Comptes, notifications, applications...", 15),
                field("event", "Le prochain grand match ou événement, et ce que tu feras à la place", "Le samedi soir, je...", 20)
            ])
        ]
    ),
    JourneyDay(
        number: 21,
        title: "Bilan de la troisième semaine",
        summary: "Tu as commencé à remplacer le jeu par autre chose. C'est là que les habitudes changent vraiment.",
        task: "Fais ton check-in, puis regarde tes badges et ton nombre de jours sans jouer. Écris ce qui te rend le plus fier cette semaine.",
        minutes: 5,
        icon: "flag.checkered",
        requirements: [
            .app(.checkInToday),
            .writing([field("proud", "Ce qui te rend le plus fier cette semaine", "Une chose, même petite...", 15)])
        ]
    ),
    JourneyDay(
        number: 22,
        title: "Anticiper les jours à risque",
        summary: "Jour de paie, vacances, dispute, anniversaire : certains jours sont plus risqués que d'autres. Mieux vaut y être préparé.",
        task: "Repère les deux prochaines dates à risque dans ton agenda et écris ce que tu prévois à chacune (qui voir, quoi faire, ce que tu évites).",
        minutes: 10,
        icon: "calendar",
        requirements: [
            .writing([
                field("d1", "Date à risque 1 et ton plan", "Le 5, jour de paie : je...", 20),
                field("d2", "Date à risque 2 et ton plan", "Le week-end du..., je...", 20)
            ])
        ]
    ),
    JourneyDay(
        number: 23,
        title: "Et si je rechute ?",
        summary: "Une rechute n'efface pas ce que tu as appris. Ce qui compte, c'est ce que tu fais dans l'heure qui suit. Prévoir ce plan à froid aide à éviter la spirale.",
        task: "Écris ce que tu ferais après une rechute : t'arrêter tout de suite, en parler à quelqu'un, l'enregistrer avec le bouton J'ai rechuté, et reprendre dès le lendemain sans te punir.",
        minutes: 10,
        icon: "arrow.triangle.2.circlepath",
        requirements: [
            .writing([field("plan", "Ton plan pour l'heure qui suit une rechute", "Je m'arrête, j'appelle..., je reprends demain...", 40)])
        ]
    ),
    JourneyDay(
        number: 24,
        title: "Retrouver la confiance",
        summary: "Le jeu abîme souvent la confiance des proches. La reconstruire passe par de petits gestes réguliers plus que par de grandes promesses.",
        task: "Fais un geste de transparence envers un proche, puis dis lequel et raconte-le.",
        minutes: 10,
        icon: "hands.sparkles.fill",
        requirements: [
            .choice(
                id: "gesture",
                prompt: "Quel geste as-tu fait ?",
                options: [
                    "J'ai partagé mon plan",
                    "J'ai montré mon avancée",
                    "J'ai remercié un proche pour son soutien",
                    "Un autre geste"
                ]
            ),
            .writing([field("detail", "Raconte-le en une phrase", "Ce que j'ai dit ou montré, et à qui...", 20)])
        ]
    ),
    JourneyDay(
        number: 25,
        title: "Le chemin parcouru",
        summary: "Regarder d'où tu viens rend plus facile de continuer.",
        task: "Compare le jour 1 et aujourd'hui : sommeil, humeur, argent, relations. Note trois choses qui ont changé, même petites.",
        minutes: 10,
        icon: "map.fill",
        requirements: [
            .writing([
                field("c1", "Changement 1", "Ce qui est différent...", 10),
                field("c2", "Changement 2", "Ce qui est différent...", 10),
                field("c3", "Changement 3", "Ce qui est différent...", 10)
            ])
        ]
    ),
    JourneyDay(
        number: 26,
        title: "Un rituel quotidien",
        summary: "Une habitude courte et régulière protège mieux qu'un grand effort ponctuel.",
        task: "Fais ton check-in, puis choisis un moment fixe de ta journée pour le refaire, en l'associant à quelque chose que tu fais déjà (café, brossage de dents, trajet).",
        minutes: 5,
        icon: "sunrise.fill",
        requirements: [
            .app(.checkInToday),
            .writing([field("moment", "Ton moment fixe et ce que tu y associes", "Chaque matin avec mon café...", 15)])
        ]
    ),
    JourneyDay(
        number: 27,
        title: "Se faire aider",
        summary: "Des professionnels accompagnent gratuitement et confidentiellement les personnes en difficulté avec le jeu, sans avoir besoin d'être au plus mal. Joueurs Info Service oriente vers les centres de soins près de chez toi.",
        task: "Va sur joueurs-info-service.fr et repère le centre d'addictologie (CSAPA) le plus proche de chez toi. Note-le, même si tu ne comptes pas y aller tout de suite.",
        minutes: 15,
        icon: "cross.case.fill",
        requirements: [
            .writing([field("center", "Nom ou ville du centre repéré", "CSAPA de...", 4)])
        ]
    ),
    JourneyDay(
        number: 28,
        title: "Ta lettre à six mois",
        summary: "Se projeter dans le futur donne un cap. Écrire à la personne que tu seras dans six mois rend cet objectif plus concret.",
        task: "Écris quelques lignes à toi-même dans six mois : ce que tu espères avoir gagné, comment tu te sens, ce que tu es fier d'avoir tenu.",
        minutes: 15,
        icon: "envelope.fill",
        requirements: [
            .writing([field("letter", "Ta lettre", "Dans six mois, j'espère que...", 80)])
        ]
    ),
    JourneyDay(
        number: 29,
        title: "Renforcer tes barrières",
        summary: "Les sites de jeu changent souvent d'adresse. Entretenir tes protections évite que les anciennes failles se rouvrent.",
        task: "Repasse dans l'onglet Blocker : vérifie que le blocage est actif et mets à jour ta liste de sites. Reviens aussi sur l'interdiction volontaire de jeux si tu ne l'as pas encore demandée.",
        minutes: 10,
        icon: "shield.lefthalf.filled",
        requirements: [
            .app(.blockerActive),
            .writing([field("check", "Ce que tu as vérifié ou mis à jour", "Sites ajoutés, blocage relancé...", 15)])
        ]
    ),
    JourneyDay(
        number: 30,
        title: "Bilan final et suite",
        summary: "Tu es allé au bout de 30 jours. L'important maintenant est de garder ce qui marche, une étape à la fois.",
        task: "Choisis une habitude de ce parcours que tu veux garder tous les jours, et une chose que tu veux améliorer le mois prochain.",
        minutes: 10,
        icon: "trophy.fill",
        requirements: [
            .writing([
                field("keep", "L'habitude que tu gardes", "Celle qui t'aide le plus...", 10),
                field("improve", "Ce que tu veux améliorer le mois prochain", "Un point à travailler...", 10)
            ])
        ]
    )
]
