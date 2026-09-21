import Foundation
import Combine
import Supabase

@MainActor
final class VictoryService: ObservableObject {
    static let shared = VictoryService()

    @Published var entries: [Victory] = []
    @Published private(set) var lastEmergencyVictoryDate: Date?

    private let client = SupabaseService.shared.client

    private init() {
        lastEmergencyVictoryDate = UserDefaults.standard.object(forKey: "lastEmergencyVictoryDate") as? Date
    }

    var canLogEmergencyVictory: Bool {
        guard let lastEmergencyVictoryDate else { return true }
        return Date().timeIntervalSince(lastEmergencyVictoryDate) >= 3 * 24 * 60 * 60
    }

    func fetchEntries() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        do {
            let response: [Victory] = try await client
                .from("victories_log")
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .execute()
                .value
            entries = response
        } catch {
            print("Erreur fetch victories: \(error)")
        }
    }

    func addEntry(note: String?) async {
        guard let userId = AuthService.shared.currentUserId else { return }

        struct NewVictory: Encodable {
            let user_id: UUID
            let note: String?
        }

        let newVictory = NewVictory(user_id: userId, note: note)

        do {
            try await client.from("victories_log").insert(newVictory).execute()
            await fetchEntries()
            AvatarStore.shared.addVitality(5)
        } catch {
            print("Erreur insert victory: \(error)")
        }
    }

    func addEmergencyVictory() async {
        guard canLogEmergencyVictory else { return }
        await addEntry(note: nil)
        lastEmergencyVictoryDate = Date()
        UserDefaults.standard.set(lastEmergencyVictoryDate, forKey: "lastEmergencyVictoryDate")
    }
}
