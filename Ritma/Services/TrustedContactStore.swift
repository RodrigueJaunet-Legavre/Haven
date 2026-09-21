import SwiftUI
import Combine

@MainActor
final class TrustedContactStore: ObservableObject {
    static let shared = TrustedContactStore()

    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: "trustedContactName") }
    }

    @Published var phone: String {
        didSet { UserDefaults.standard.set(phone, forKey: "trustedContactPhone") }
    }

    @Published var pendingPrompt = false

    var hasContact: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var emergencyOpenTimestamps: [Date] {
        get { (UserDefaults.standard.array(forKey: "emergencyOpenTimestamps") as? [Date]) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "emergencyOpenTimestamps") }
    }

    private init() {
        name = UserDefaults.standard.string(forKey: "trustedContactName") ?? ""
        phone = UserDefaults.standard.string(forKey: "trustedContactPhone") ?? ""
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
