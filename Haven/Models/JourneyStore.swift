import SwiftUI
import Combine

@MainActor
final class JourneyStore: ObservableObject {
    static let shared = JourneyStore()

    @Published private(set) var startDate: Date?
    @Published private(set) var completedDays: Set<Int>

    private init() {
        startDate = UserDefaults.standard.object(forKey: "journeyStartDate") as? Date
        let saved = UserDefaults.standard.array(forKey: "journeyCompletedDays") as? [Int] ?? []
        completedDays = Set(saved)
    }

    var hasStarted: Bool { startDate != nil }

    var currentDayNumber: Int {
        guard let startDate else { return 0 }
        let calendar = Calendar.current
        let elapsed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0
        return min(max(elapsed + 1, 1), journeyDays.count)
    }

    var completedCount: Int { completedDays.count }

    var isFinished: Bool { completedCount >= journeyDays.count }

    var progress: Double { Double(completedCount) / Double(journeyDays.count) }

    var nextDayToDo: JourneyDay? {
        journeyDays.first { isUnlocked($0) && !isCompleted($0) }
    }

    func isUnlocked(_ day: JourneyDay) -> Bool {
        hasStarted && day.number <= currentDayNumber
    }

    func isCompleted(_ day: JourneyDay) -> Bool {
        completedDays.contains(day.number)
    }

    func unlockDate(for day: JourneyDay) -> Date? {
        guard let startDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: day.number - 1, to: Calendar.current.startOfDay(for: startDate))
    }

    func start() {
        startDate = Date()
        persist()
    }

    func complete(_ day: JourneyDay) {
        guard isUnlocked(day), !isCompleted(day) else { return }
        completedDays.insert(day.number)
        persist()
        AvatarStore.shared.addVitality(4)
    }

    func restart() {
        startDate = nil
        completedDays = []
        persist()
    }

    #if DEBUG
    func advanceOneDayForTesting() {
        guard let startDate, let earlier = Calendar.current.date(byAdding: .day, value: -1, to: startDate) else { return }
        self.startDate = earlier
        persist()
    }
    #endif

    private func persist() {
        if let startDate {
            UserDefaults.standard.set(startDate, forKey: "journeyStartDate")
        } else {
            UserDefaults.standard.removeObject(forKey: "journeyStartDate")
        }
        UserDefaults.standard.set(Array(completedDays), forKey: "journeyCompletedDays")
    }
}
