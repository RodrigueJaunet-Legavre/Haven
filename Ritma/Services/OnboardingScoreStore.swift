import SwiftUI
import Combine

@MainActor
final class OnboardingScoreStore: ObservableObject {
    static let shared = OnboardingScoreStore()

    var pgsiScore: Int = 0
    var durationImpact: Int = 0
    var frequencyImpact: Int = 0
    var stakeImpact: Int = 0
    var totalHistoryImpact: Int = 0

    var selectedGames: [GameType] = []
    var stakes: [GameType: Double] = [:]
    var frequencyLabels: [GameType: String] = [:]

    private init() {}

    func finalizeVitalityScore() {
        let ratio = Double(pgsiScore) / 30.0
        let base = 100 - ratio * 100
        let totalImpact = Double(durationImpact + frequencyImpact + stakeImpact + totalHistoryImpact)
        AvatarStore.shared.vitalityScore = max(0, min(100, base - totalImpact))
    }
}
