import SwiftUI
import Combine

@MainActor
final class EmergencyReasonsStore: ObservableObject {
    static let shared = EmergencyReasonsStore()

    @Published var reasons: [EmergencyReason] {
        didSet { save() }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: "emergencyReasons"),
           let decoded = try? JSONDecoder().decode([EmergencyReason].self, from: data) {
            reasons = decoded
        } else {
            reasons = []
        }
    }

    func addReason(_ text: String) {
        reasons.append(EmergencyReason(id: UUID(), text: text))
    }

    func deleteReason(at offsets: IndexSet) {
        reasons.remove(atOffsets: offsets)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(reasons) {
            UserDefaults.standard.set(data, forKey: "emergencyReasons")
        }
    }
}
