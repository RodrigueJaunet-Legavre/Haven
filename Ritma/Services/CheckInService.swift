import Foundation
import Combine
import Supabase

@MainActor
final class CheckInService: ObservableObject {
    static let shared = CheckInService()

    @Published var entries: [CheckIn] = []

    private let client = SupabaseService.shared.client

    private init() {}

    var hasCheckedInToday: Bool {
        guard let last = entries.first else { return false }
        return Calendar.current.isDateInToday(last.date)
    }

    func fetchEntries() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        do {
            let response: [CheckIn] = try await client
                .from("checkins_log")
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .execute()
                .value
            entries = response
        } catch {
            print("Erreur fetch checkins: \(error)")
        }
    }

    func addEntry(intensity: Int) async {
        guard let userId = AuthService.shared.currentUserId else { return }

        struct NewCheckIn: Encodable {
            let user_id: UUID
            let intensity: Int
        }

        do {
            try await client.from("checkins_log").insert(NewCheckIn(user_id: userId, intensity: intensity)).execute()
            await fetchEntries()
        } catch {
            print("Erreur insert checkin: \(error)")
        }
    }
}
