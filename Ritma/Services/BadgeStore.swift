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
        let saved = UserDefaults.standard.array(forKey: "unlockedBadgeIDs") as? [String] ?? []
        unlockedBadgeIDs = Set(saved)
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
        UserDefaults.standard.set(Array(unlockedBadgeIDs), forKey: "unlockedBadgeIDs")
        pendingUnlocks.append(contentsOf: newlyUnlocked.map { BadgeUnlockEvent(badge: $0) })
    }

    func dismissCurrentUnlock() {
        guard !pendingUnlocks.isEmpty else { return }
        pendingUnlocks.removeFirst()
    }
}
