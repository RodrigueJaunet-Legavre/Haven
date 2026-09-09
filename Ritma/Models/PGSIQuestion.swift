import Foundation

struct PGSIQuestion: Identifiable {
    let id: Int
    let text: String
    let imageName: String
}

let pgsiQuestions: [PGSIQuestion] = [
    PGSIQuestion(id: 0, text: "Avez-vous déjà misé plus d'argent que vous ne pouviez vraiment vous permettre de perdre ?", imageName: "PGSI_0"),
    PGSIQuestion(id: 1, text: "Avez-vous eu besoin de miser des sommes de plus en plus importantes pour ressentir la même excitation ?", imageName: "PGSI_1"),
    PGSIQuestion(id: 2, text: "Avez-vous rejoué un autre jour pour récupérer l'argent perdu en jouant ?", imageName: "PGSI_2"),
    PGSIQuestion(id: 3, text: "Avez-vous emprunté de l'argent ou vendu quelque chose pour obtenir de l'argent pour jouer ?", imageName: "PGSI_3"),
    PGSIQuestion(id: 4, text: "Avez-vous déjà pensé que vous pourriez avoir un problème avec le jeu ?", imageName: "PGSI_4"),
    PGSIQuestion(id: 5, text: "Le jeu vous a-t-il causé des problèmes de santé, y compris du stress ou de l'anxiété ?", imageName: "PGSI_5"),
    PGSIQuestion(id: 6, text: "Des personnes ont-elles critiqué vos habitudes de jeu ou dit que vous aviez un problème, que ce soit vrai ou non ?", imageName: "PGSI_6"),
    PGSIQuestion(id: 7, text: "Vos habitudes de jeu ont-elles causé des difficultés financières pour vous ou votre foyer ?", imageName: "PGSI_7"),
    PGSIQuestion(id: 8, text: "Avez-vous déjà menti à vos proches à cause du jeu ?", imageName: "PGSI_8")
]

let pgsiAnswerOptions: [(label: String, score: Int)] = [
    ("Jamais", 0),
    ("Une fois ou deux", 1),
    ("Parfois", 2),
    ("Souvent", 3)
]

enum PGSIRiskCategory: String {
    case none = "Tout va bien pour l'instant"
    case low = "Une vigilance à garder"
    case moderate = "C'est le bon moment pour du soutien"
    case high = "Un accompagnement te ferait du bien"

    static func from(score: Int) -> PGSIRiskCategory {
        switch score {
        case 0: return .none
        case 1...2: return .low
        case 3...7: return .moderate
        default: return .high
        }
    }
}
