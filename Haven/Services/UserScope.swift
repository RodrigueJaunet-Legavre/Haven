import Foundation

enum UserScope {
    private static let onboardingKeys = [
        "pgsiInitialScore",
        "pgsiInitialCategory",
        "pgsiTestDate",
        "estimatedAnnualLoss",
        "initialVitalityScore"
    ]

    static func suiteName(for id: String) -> String {
        "haven.user.\(id)"
    }

    static var defaults: UserDefaults {
        let id = AuthService.shared.currentUserId?.uuidString ?? "anonymous"
        return UserDefaults(suiteName: suiteName(for: id)) ?? .standard
    }

    static func adoptOnboardingData() {
        guard AuthService.shared.currentUserId != nil,
              let anonymous = UserDefaults(suiteName: suiteName(for: "anonymous")) else { return }

        let target = defaults
        for key in onboardingKeys {
            if target.object(forKey: key) == nil, let value = anonymous.object(forKey: key) {
                target.set(value, forKey: key)
            }
            anonymous.removeObject(forKey: key)
        }
    }
}
