import SwiftUI
import Combine

@MainActor
final class TrustedContactStore: ObservableObject {
    static let shared = TrustedContactStore()

    @Published var name: String {
        didSet { UserScope.defaults.set(name, forKey: "trustedContactName") }
    }

    @Published var phone: String {
        didSet { UserScope.defaults.set(phone, forKey: "trustedContactPhone") }
    }

    @Published var pendingPrompt = false

    var hasContact: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var emergencyOpenTimestamps: [Date] {
        get { (UserScope.defaults.array(forKey: "emergencyOpenTimestamps") as? [Date]) ?? [] }
        set { UserScope.defaults.set(newValue, forKey: "emergencyOpenTimestamps") }
    }

    private init() {
        name = UserScope.defaults.string(forKey: "trustedContactName") ?? ""
        phone = UserScope.defaults.string(forKey: "trustedContactPhone") ?? ""
    }

    func reloadForCurrentUser() {
        name = UserScope.defaults.string(forKey: "trustedContactName") ?? ""
        phone = UserScope.defaults.string(forKey: "trustedContactPhone") ?? ""
        pendingPrompt = false
    }

    func recordEmergencyOpen() {
        guard hasContact else { return }
        var timestamps = emergencyOpenTimestamps
        timestamps.append(Date())
        let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
        timestamps = timestamps.filter { $0 > cutoff }
        emergencyOpenTimestamps = timestamps

        if timestamps.count >= 3 {
            pendingPrompt = true
        }
    }

    func recordRelapse() {
        guard hasContact else { return }
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        let recentRelapses = BetsService.shared.entries.filter {
            $0.type_jeu == "Rechute" && $0.date > cutoff
        }
        if recentRelapses.count >= 2 {
            pendingPrompt = true
        }
    }
}
