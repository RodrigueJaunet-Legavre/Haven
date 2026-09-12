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
        let today = Self.todayKey()
        let lastResetDate = UserDefaults.standard.string(forKey: "activityResetDate") ?? ""

        if lastResetDate == today,
           let saved = UserDefaults.standard.array(forKey: "completedActivitiesToday") as? [String] {
            completedToday = Set(saved)
        } else {
            completedToday = []
            UserDefaults.standard.set(today, forKey: "activityResetDate")
            UserDefaults.standard.removeObject(forKey: "completedActivitiesToday")
        }
    }

    func isCompleted(_ activity: ReplacementActivity) -> Bool {
        completedToday.contains(activity.id)
    }

    func complete(_ activity: ReplacementActivity) {
        guard !completedToday.contains(activity.id) else { return }
        guard !hasReachedDailyLimit else { return }
        completedToday.insert(activity.id)
        UserDefaults.standard.set(Array(completedToday), forKey: "completedActivitiesToday")

        AvatarStore.shared.addVitality(Double(activity.points))
    }

    func resetToday() {
        completedToday = []
        UserDefaults.standard.set(Self.todayKey(), forKey: "activityResetDate")
        UserDefaults.standard.removeObject(forKey: "completedActivitiesToday")
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
