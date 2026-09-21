import Foundation

struct CheckIn: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let date: Date
    let intensity: Int
}

enum CheckInLevel: Int, CaseIterable, Identifiable {
    case none = 1
    case slight = 2
    case moderate = 3
    case strong = 4
    case veryStrong = 5

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .none: return "😌"
        case .slight: return "🙂"
        case .moderate: return "😐"
        case .strong: return "😟"
        case .veryStrong: return "😰"
        }
    }

    var label: String {
        switch self {
        case .none: return "Aucune envie"
        case .slight: return "Légère"
        case .moderate: return "Modérée"
        case .strong: return "Forte"
        case .veryStrong: return "Très forte"
        }
    }
}
