import Foundation
import Supabase
import Combine

@MainActor
final class BetsService: ObservableObject {
    static let shared = BetsService()

    @Published var entries: [BetLogEntry] = []

    private let client = SupabaseService.shared.client

    private init() {}

    func fetchEntries() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        do {
            let response: [BetLogEntry] = try await client
                .from("bets_log")
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .execute()
                .value
            entries = response
        } catch {
            print("Erreur fetch bets: \(error)")
        }
    }

    func addEntry(typeJeu: String, montant: Double, gainPerte: Double?) async {
        guard let userId = AuthService.shared.currentUserId else { return }

        struct NewBet: Encodable {
            let user_id: UUID
            let montant: Double
            let type_jeu: String
            let gain_perte: Double?
        }

        let newBet = NewBet(user_id: userId, montant: montant, type_jeu: typeJeu, gain_perte: gainPerte)

        do {
            try await client.from("bets_log").insert(newBet).execute()
            await fetchEntries()
            applyRelapsePenalty()
            await StreakStore.shared.refresh()
        } catch {
            print("Erreur insert bet: \(error)")
        }
    }

    private func applyRelapsePenalty() {
        let store = AvatarStore.shared
        store.vitalityScore = max(0, store.vitalityScore - 25)
    }
}
