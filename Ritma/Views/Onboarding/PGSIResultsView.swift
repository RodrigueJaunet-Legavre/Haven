import SwiftUI

struct PGSIResultsView: View {
    let score: Int
    let category: PGSIRiskCategory

    @State private var isVisible = false
    @State private var goToSignUp = false

    private let store = OnboardingScoreStore.shared

    private func sessionsPerYear(_ label: String?) -> Double {
        switch label {
        case "Quotidien": return 365
        case "Plusieurs fois/semaine": return 156
        case "Une fois/semaine": return 52
        case "Quelques fois/mois": return 24
        case "Rarement": return 6
        default: return 12
        }
    }

    private var annualWagered: Double {
        store.selectedGames.reduce(0) { partial, game in
            let stake = store.stakes[game] ?? 0
            let sessions = sessionsPerYear(store.frequencyLabels[game])
            return partial + stake * sessions
        }
    }

    private var estimatedAnnualLoss: Double {
        annualWagered * 0.8
    }

    private var equivalent: String {
        switch estimatedAnnualLoss {
        case ..<300: return "quelques sorties restaurant"
        case 300..<1000: return "un smartphone récent"
        case 1000..<3000: return "un city trip pour deux"
        case 3000..<8000: return "des vacances à l'étranger"
        default: return "un apport pour un projet important"
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 30)

                        scoreGauge

                        statCard(
                            icon: "banknote.fill",
                            title: "Estimation misée sur 12 mois",
                            value: formatted(annualWagered),
                            tint: Color.appGold
                        )

                        statCard(
                            icon: "arrow.down.right.circle.fill",
                            title: "Perte probable estimée sur 12 mois",
                            value: formatted(estimatedAnnualLoss),
                            tint: Color.appDanger
                        )

                        equivalentCard

                        practiceSummary

                        Text("Ces chiffres sont des estimations illustratives basées sur tes réponses, pas des montants garantis.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.appTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 28)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 12)
                }

                Button("Continuer") {
                    OnboardingScoreStore.shared.pgsiScore = score
                    OnboardingScoreStore.shared.finalizeVitalityScore()
                    goToSignUp = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationDestination(isPresented: $goToSignUp) {
            PaywallView()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.appSpring.delay(0.1)) {
                isVisible = true
            }
        }
    }

    private var scoreGauge: some View {
        VStack(spacing: 14) {
            Text("Ton score")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextMuted)

            Text("\(score)/30")
                .font(.appDisplay)
                .foregroundStyle(Color.appTextPrimary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appSurfaceElevated).frame(height: 10)
                    Capsule()
                        .fill(Color.appAccent)
                        .frame(width: geo.size.width * CGFloat(min(score, 30)) / 30, height: 10)
                }
            }
            .frame(height: 10)

            Text(category.rawValue)
                .font(.appHeadline)
                .foregroundStyle(Color.appAccent)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.appSurface))
    }

    private func statCard(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(tint.opacity(0.18)).frame(width: 46, height: 46)
                Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
            }

            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.appSurface))
    }

    private var equivalentCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appGold)

            Text("Ça représente à peu près \(equivalent).")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.appGold.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18).stroke(Color.appGold.opacity(0.4), lineWidth: 1)
        )
    }

    private var practiceSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ta pratique déclarée")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)

            ForEach(store.selectedGames) { game in
                HStack {
                    Text(game.title)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(store.frequencyLabels[game] ?? "")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("· \(Int(store.stakes[game] ?? 0)) €/session")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextMuted)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.appSurface))
    }

    private func formatted(_ value: Double) -> String {
        Int(value).formatted(.number.locale(Locale(identifier: "fr_FR"))) + " €"
    }
}

#Preview {
    NavigationStack {
        PGSIResultsView(score: 12, category: .moderate)
    }
}
