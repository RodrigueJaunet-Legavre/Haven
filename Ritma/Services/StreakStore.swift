import SwiftUI
import Combine

@MainActor
final class StreakStore: ObservableObject {
    static let shared = StreakStore()

    @Published var streakDays: Int = 0

    private init() {}

    func refresh() async {
        await BetsService.shared.fetchEntries()
        let lastBetDate = BetsService.shared.entries.first?.date

        let referenceDate = lastBetDate ?? accountCreationDate()
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: referenceDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0

        streakDays = max(0, days)
        applyDailyBonusIfNeeded()
    }

    private func accountCreationDate() -> Date {
        if let stored = UserDefaults.standard.object(forKey: "accountCreationDate") as? Date {
            return stored
        }
        let now = Date()
        UserDefaults.standard.set(now, forKey: "accountCreationDate")
        return now
    }

    private func applyDailyBonusIfNeeded() {
        let todayKey = Self.todayKey()
        let lastBonusDate = UserDefaults.standard.string(forKey: "lastStreakBonusDate") ?? ""
        guard lastBonusDate != todayKey else { return }

        UserDefaults.standard.set(todayKey, forKey: "lastStreakBonusDate")
        guard streakDays > 0 else { return }

        AvatarStore.shared.addVitality(3)
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
