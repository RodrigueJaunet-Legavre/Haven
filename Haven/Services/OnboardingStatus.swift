import SwiftUI
import Combine

@MainActor
final class OnboardingStatus: ObservableObject {
    static let shared = OnboardingStatus()

    @Published private(set) var isCompleted: Bool

    private init() {
        isCompleted = Self.loadCompleted()
    }

    func reloadForCurrentUser() {
        isCompleted = Self.loadCompleted()
    }

    func markCompleted() {
        isCompleted = true
    }

    private static func loadCompleted() -> Bool {
        UserScope.defaults.object(forKey: "pgsiInitialScore") != nil
    }
}
