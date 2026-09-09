import Foundation

enum GameType: String, Identifiable {
    case casino
    case sportsBetting

    var id: String { rawValue }

    var title: String {
        switch self {
        case .casino: return "Casino"
        case .sportsBetting: return "Paris sportifs"
        }
    }
}
