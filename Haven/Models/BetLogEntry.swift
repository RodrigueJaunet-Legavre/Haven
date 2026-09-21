import Foundation

struct BetLogEntry: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let date: Date
    let montant: Double
    let type_jeu: String
    let gain_perte: Double?
}
