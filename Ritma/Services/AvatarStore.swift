import SwiftUI
import Combine

@MainActor
final class AvatarStore: ObservableObject {
    static let shared = AvatarStore()

    @Published var config: AvatarConfig {
        didSet { saveConfig() }
    }

    @Published var vitalityScore: Double {
        didSet { UserDefaults.standard.set(vitalityScore, forKey: "vitalityScore") }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: "avatarConfig"),
           let decoded = try? JSONDecoder().decode(AvatarConfig.self, from: data) {
            config = decoded
        } else {
            config = .default
        }
        vitalityScore = UserDefaults.standard.object(forKey: "vitalityScore") as? Double ?? 50
    }

    private func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: "avatarConfig")
        }
    }
}
