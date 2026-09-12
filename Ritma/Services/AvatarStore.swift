import SwiftUI
import Combine

struct VitalityGainEvent: Identifiable {
    let id = UUID()
    let oldScore: Double
    let newScore: Double
    let amount: Double
}

@MainActor
final class AvatarStore: ObservableObject {
    static let shared = AvatarStore()

    @Published var config: AvatarConfig {
        didSet { saveConfig() }
    }

    @Published var vitalityScore: Double {
        didSet { UserDefaults.standard.set(vitalityScore, forKey: "vitalityScore") }
    }

    @Published var pendingGain: VitalityGainEvent?

    private init() {
        if let data = UserDefaults.standard.data(forKey: "avatarConfig"),
           let decoded = try? JSONDecoder().decode(AvatarConfig.self, from: data) {
            config = decoded
        } else {
            config = .default
        }
        vitalityScore = UserDefaults.standard.object(forKey: "vitalityScore") as? Double ?? 50
    }

    func addVitality(_ amount: Double) {
        let old = vitalityScore
        let new = max(0, min(100, old + amount))
        vitalityScore = new
        pendingGain = VitalityGainEvent(oldScore: old, newScore: new, amount: amount)
    }

    static func tier(for score: Double) -> Int {
        switch score {
        case ..<35: return 1
        case 35..<60: return 2
        case 60..<75: return 3
        case 75..<90: return 4
        default: return 5
        }
    }

    private func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: "avatarConfig")
        }
    }
}
