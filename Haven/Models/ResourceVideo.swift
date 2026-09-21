import Foundation

struct ResourceVideo: Identifiable {
    let id = UUID()
    let title: String
    let speakerRole: String
    let duration: String
    let description: String
}

let resourceVideos: [ResourceVideo] = [
    ResourceVideo(
        title: "Pourquoi le cerveau s'accroche au jeu",
        speakerRole: "Addictologue",
        duration: "6 min",
        description: "Explication du mécanisme de récompense et de tolérance qui entretient l'envie de rejouer, même après une perte."
    ),
    ResourceVideo(
        title: "Sortir du cycle de la rechute",
        speakerRole: "Psychologue clinicien",
        duration: "8 min",
        description: "Les déclencheurs les plus fréquents avant une rechute et comment les repérer avant qu'ils ne deviennent difficiles à gérer."
    ),
    ResourceVideo(
        title: "Témoignage : comment j'ai arrêté",
        speakerRole: "Ancien joueur",
        duration: "10 min",
        description: "Un parcours personnel de sortie de l'addiction, avec ses difficultés concrètes et ce qui a fait la différence."
    )
]
