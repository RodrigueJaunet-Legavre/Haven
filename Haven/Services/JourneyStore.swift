import SwiftUI
import Combine
import FamilyControls

@MainActor
final class JourneyStore: ObservableObject {
    static let shared = JourneyStore()

    @Published private(set) var startDate: Date?
    @Published private(set) var completedDays: Set<Int>
    @Published private(set) var answers: [String: String]
    @Published private(set) var lastSeenNode: Int
    @Published var pendingCelebrationNode: Int?

    private var reasonsBaseline: Int

    private init() {
        startDate = Self.loadStartDate()
        completedDays = Self.loadCompletedDays()
        answers = Self.loadAnswers()
        lastSeenNode = Self.loadLastSeenNode()
        reasonsBaseline = Self.loadReasonsBaseline()
    }

    func reloadForCurrentUser() {
        startDate = Self.loadStartDate()
        completedDays = Self.loadCompletedDays()
        answers = Self.loadAnswers()
        lastSeenNode = Self.loadLastSeenNode()
        reasonsBaseline = Self.loadReasonsBaseline()
        pendingCelebrationNode = nil
    }

    var hasStarted: Bool { startDate != nil }

    var completedCount: Int { completedDays.count }

    var isFinished: Bool { completedCount >= journeyDays.count }

    var currentDay: JourneyDay? {
        journeyDays.first { $0.number == completedCount + 1 }
    }

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

    var avatarTargetNode: Int {
        guard hasStarted else { return 0 }
        return min(completedCount + 1, journeyDays.count)
    }

    var nextDayToDo: JourneyDay? {
        guard hasStarted, let day = currentDay, isUnlocked(day) else { return nil }
        return day
    }

    var isWaitingForNextDay: Bool {
        guard hasStarted, let day = currentDay else { return false }
        return !isUnlocked(day)
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

    func answer(day: Int, field: String) -> String {
        answers["d\(day)-\(field)"] ?? ""
    }

    func setAnswer(_ value: String, day: Int, field: String) {
        answers["d\(day)-\(field)"] = value
        UserScope.defaults.set(answers, forKey: "journeyAnswers")
    }

    func isSatisfied(_ requirement: JourneyRequirement, for day: JourneyDay) -> Bool {
        switch requirement {
        case .writing(let fields):
            return fields.allSatisfy { field in
                answer(day: day.number, field: field.id).trimmingCharacters(in: .whitespacesAndNewlines).count >= field.minCharacters
            }
        case .choice(let id, _, _):
            return !answer(day: day.number, field: id).isEmpty
        case .app(let check):
            return isAppCheckSatisfied(check)
        case .breathing:
            return answer(day: day.number, field: "breathing") == "done"
        }
    }

    func canComplete(_ day: JourneyDay) -> Bool {
        guard hasStarted, day.number == completedCount + 1, isUnlocked(day) else { return false }
        return day.requirements.allSatisfy { isSatisfied($0, for: day) }
    }

    private func isAppCheckSatisfied(_ check: JourneyAppCheck) -> Bool {
        switch check {
        case .blockerActive:
            let blocker = BlockerStore.shared
            let hasTargets = blocker.blockedDomains.count >= 5
                || !blocker.selection.applicationTokens.isEmpty
                || !blocker.selection.categoryTokens.isEmpty
            return blocker.isAuthorized && blocker.isBlockingEnabled && hasTargets
        case .trustedContact:
            return TrustedContactStore.shared.hasContact
        case .checkInToday:
            return CheckInService.shared.hasCheckedInToday
        case .emergencyReasonAdded:
            return EmergencyReasonsStore.shared.reasons.count > reasonsBaseline
        }
    }

    func start() {
        startDate = Date()
        reasonsBaseline = EmergencyReasonsStore.shared.reasons.count
        lastSeenNode = 0
        persist()
    }

    func complete(_ day: JourneyDay) {
        guard canComplete(day) else { return }
        completedDays.insert(day.number)
        pendingCelebrationNode = day.number
        persist()
        AvatarStore.shared.addVitality(4)
    }

    func consumeCelebration() -> Int? {
        let node = pendingCelebrationNode
        pendingCelebrationNode = nil
        return node
    }

    func setLastSeenNode(_ node: Int) {
        lastSeenNode = node
        UserScope.defaults.set(node, forKey: "journeyLastSeenNode")
    }

    func restart() {
        startDate = nil
        completedDays = []
        answers = [:]
        lastSeenNode = 0
        pendingCelebrationNode = nil
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
        let defaults = UserScope.defaults
        if let startDate {
            defaults.set(startDate, forKey: "journeyStartDate")
        } else {
            defaults.removeObject(forKey: "journeyStartDate")
        }
        defaults.set(Array(completedDays), forKey: "journeyCompletedDays")
        defaults.set(answers, forKey: "journeyAnswers")
        defaults.set(lastSeenNode, forKey: "journeyLastSeenNode")
        defaults.set(reasonsBaseline, forKey: "journeyReasonsBaseline")
    }

    private static func loadStartDate() -> Date? {
        UserScope.defaults.object(forKey: "journeyStartDate") as? Date
    }

    private static func loadCompletedDays() -> Set<Int> {
        Set(UserScope.defaults.array(forKey: "journeyCompletedDays") as? [Int] ?? [])
    }

    private static func loadAnswers() -> [String: String] {
        UserScope.defaults.dictionary(forKey: "journeyAnswers") as? [String: String] ?? [:]
    }

    private static func loadLastSeenNode() -> Int {
        UserScope.defaults.integer(forKey: "journeyLastSeenNode")
    }

    private static func loadReasonsBaseline() -> Int {
        UserScope.defaults.integer(forKey: "journeyReasonsBaseline")
    }
}
