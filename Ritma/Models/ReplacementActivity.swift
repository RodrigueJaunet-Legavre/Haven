import Foundation

struct ReplacementActivity: Identifiable {
    let id: String
    let icon: String
    let title: String
    let explanation: String
    let points: Int
}

let replacementActivities: [ReplacementActivity] = [
    ReplacementActivity(
        id: "exercise",
        icon: "figure.run",
        title: "10 minutes d'exercice intense",
        explanation: "Libère des endorphines et de la dopamine en quelques minutes seulement, avec un effet quasi immédiat sur l'humeur.",
        points: 3
    ),
    ReplacementActivity(
        id: "cold_shower",
        icon: "snowflake",
        title: "Une douche froide",
        explanation: "L'exposition au froid provoque un pic de dopamine documenté scientifiquement, comparable en intensité à d'autres sources de plaisir.",
        points: 2
    ),
    ReplacementActivity(
        id: "music",
        icon: "music.note",
        title: "Écouter un titre qui te fait vibrer",
        explanation: "La musique qu'on aime active directement le circuit de récompense du cerveau, le même que celui sollicité par le jeu.",
        points: 1
    ),
    ReplacementActivity(
        id: "call_friend",
        icon: "phone.fill",
        title: "Appeler un proche",
        explanation: "Le contact social libère de l'ocytocine et de la dopamine, et casse l'isolement qui accompagne souvent l'envie de jouer.",
        points: 2
    ),
    ReplacementActivity(
        id: "creative",
        icon: "paintbrush.fill",
        title: "Une activité créative",
        explanation: "Dessiner, écrire ou faire de la musique active un état de flow qui procure une satisfaction durable, sans risque financier.",
        points: 3
    ),
    ReplacementActivity(
        id: "gaming",
        icon: "gamecontroller.fill",
        title: "Un jeu vidéo sans argent réel",
        explanation: "Stimule un circuit de récompense similaire à travers le défi et la progression, sans aucune perte financière possible.",
        points: 2
    )
]
