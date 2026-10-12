import SwiftUI
import Combine

struct BadgeUnlockEvent: Identifiable {
    let id = UUID()
    let badge: Badge
}

@MainActor
final class BadgeStore: ObservableObject {
    static let shared = BadgeStore()

    @Published private(set) var unlockedBadgeIDs: Set<String>
    @Published var pendingUnlocks: [BadgeUnlockEvent] = []

    private init() {
        unlockedBadgeIDs = Self.loadUnlockedBadgeIDs()
    }

    func reloadForCurrentUser() {
        unlockedBadgeIDs = Self.loadUnlockedBadgeIDs()
        pendingUnlocks = []
    }

    func isUnlocked(_ badge: Badge) -> Bool {
        unlockedBadgeIDs.contains(badge.id)
    }

    func checkMilestones(streakDays: Int) {
        var newlyUnlocked: [Badge] = []
        for badge in allBadges where streakDays >= badge.thresholdDays && !unlockedBadgeIDs.contains(badge.id) {
            unlockedBadgeIDs.insert(badge.id)
            newlyUnlocked.append(badge)
        }
        guard !newlyUnlocked.isEmpty else { return }
        UserScope.defaults.set(Array(unlockedBadgeIDs), forKey: "unlockedBadgeIDs")
        pendingUnlocks.append(contentsOf: newlyUnlocked.map { BadgeUnlockEvent(badge: $0) })
    }

    func dismissCurrentUnlock() {
        guard !pendingUnlocks.isEmpty else { return }
        pendingUnlocks.removeFirst()
    }

    private static func loadUnlockedBadgeIDs() -> Set<String> {
        Set(UserScope.defaults.array(forKey: "unlockedBadgeIDs") as? [String] ?? [])
    }
}
