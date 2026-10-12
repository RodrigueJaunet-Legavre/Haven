import SwiftUI
import Combine

@MainActor
final class ActivityCompletionStore: ObservableObject {
    static let shared = ActivityCompletionStore()

    static let maxActivitiesPerDay = 3

    @Published private(set) var completedToday: Set<String> = []

    var hasReachedDailyLimit: Bool {
        completedToday.count >= Self.maxActivitiesPerDay
    }

    private init() {
        completedToday = Self.loadCompletedToday()
    }

    func reloadForCurrentUser() {
        completedToday = Self.loadCompletedToday()
    }

    func isCompleted(_ activity: ReplacementActivity) -> Bool {
        completedToday.contains(activity.id)
    }

    func complete(_ activity: ReplacementActivity) {
        guard !completedToday.contains(activity.id) else { return }
        guard !hasReachedDailyLimit else { return }
        completedToday.insert(activity.id)
        UserScope.defaults.set(Array(completedToday), forKey: "completedActivitiesToday")

        AvatarStore.shared.addVitality(Double(activity.points))
    }

    func resetToday() {
        completedToday = []
        UserScope.defaults.set(Self.todayKey(), forKey: "activityResetDate")
        UserScope.defaults.removeObject(forKey: "completedActivitiesToday")
    }

    private static func loadCompletedToday() -> Set<String> {
        let today = todayKey()
        let defaults = UserScope.defaults
        let lastResetDate = defaults.string(forKey: "activityResetDate") ?? ""

        if lastResetDate == today,
           let saved = defaults.array(forKey: "completedActivitiesToday") as? [String] {
            return Set(saved)
        } else {
            defaults.set(today, forKey: "activityResetDate")
            defaults.removeObject(forKey: "completedActivitiesToday")
            return []
        }
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
