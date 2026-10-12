import SwiftUI
import Combine

@MainActor
final class EmergencyReasonsStore: ObservableObject {
    static let shared = EmergencyReasonsStore()

    @Published var reasons: [EmergencyReason] {
        didSet { save() }
    }

    @Published private(set) var setupCompleted: Bool

    private init() {
        let loaded = Self.loadReasons()
        reasons = loaded
        setupCompleted = Self.loadSetupCompleted(reasonCount: loaded.count)
    }

    func reloadForCurrentUser() {
        let loaded = Self.loadReasons()
        reasons = loaded
        setupCompleted = Self.loadSetupCompleted(reasonCount: loaded.count)
    }

    func addReason(_ text: String) {
        reasons.append(EmergencyReason(id: UUID(), text: text))
    }

    func deleteReason(at offsets: IndexSet) {
        reasons.remove(atOffsets: offsets)
    }

    func completeSetup() {
        setupCompleted = true
        UserScope.defaults.set(true, forKey: "emergencySetupCompleted")
    }

    private func save() {
        if let data = try? JSONEncoder().encode(reasons) {
            UserScope.defaults.set(data, forKey: "emergencyReasons")
        }
    }

    private static func loadReasons() -> [EmergencyReason] {
        if let data = UserScope.defaults.data(forKey: "emergencyReasons"),
           let decoded = try? JSONDecoder().decode([EmergencyReason].self, from: data) {
            return decoded
        }
        return []
    }

    private static func loadSetupCompleted(reasonCount: Int) -> Bool {
        UserScope.defaults.bool(forKey: "emergencySetupCompleted") || reasonCount >= 3
    }
}
