import SwiftUI

struct PracticeDetailsView: View {
    let selectedGames: [GameType]

    @State private var isVisible = false
    @State private var frequencies: [GameType: String] = [:]
    @State private var stakes: [GameType: String] = [:]
    @State private var durations: [GameType: String] = [:]
    @State private var goToTotalHistory = false
    @FocusState private var focusedField: GameType?

    private let frequencyOptions: [(label: String, impact: Int)] = [
        ("Quotidien", 20),
        ("Plusieurs fois/semaine", 15),
        ("Une fois/semaine", 10),
        ("Quelques fois/mois", 5),
        ("Rarement", 0)
    ]

    private let durationOptions: [(label: String, impact: Int)] = [
        ("Moins de 6 mois", 0),
        ("6 mois à 1 an", 5),
        ("1 à 3 ans", 10),
        ("3 à 5 ans", 15),
        ("Plus de 5 ans", 20)
    ]

    private var isComplete: Bool {
        selectedGames.allSatisfy { game in
            frequencies[game] != nil && !(stakes[game]?.isEmpty ?? true) && durations[game] != nil
        }
    }

    private func stakeImpact(for montant: Double) -> Int {
        switch montant {
        case ..<20: return 0
        case 20..<50: return 5
        case 50..<100: return 10
        case 100..<300: return 15
        default: return 20
        }
    }

    private var durationImpact: Int {
        selectedGames.compactMap { game in
            durations[game].flatMap { label in
                durationOptions.first(where: { $0.label == label })?.impact
            }
        }.max() ?? 0
    }

    private var frequencyImpact: Int {
        selectedGames.compactMap { game in
            frequencies[game].flatMap { label in
                frequencyOptions.first(where: { $0.label == label })?.impact
            }
        }.max() ?? 0
    }

    private var stakeImpactValue: Int {
        selectedGames.compactMap { game in
            stakes[game].flatMap { Double($0) }.map { stakeImpact(for: $0) }
        }.max() ?? 0
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 50)

                headerBlock
                    .padding(.horizontal, 28)

                Spacer(minLength: 32)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ForEach(selectedGames) { game in
                            gameCard(for: game)
                        }
                    }
                    .padding(.horizontal, 28)
                }

                Button("Continuer") {
                    OnboardingScoreStore.shared.durationImpact = durationImpact
                    OnboardingScoreStore.shared.frequencyImpact = frequencyImpact
                    OnboardingScoreStore.shared.stakeImpact = stakeImpactValue
                    OnboardingScoreStore.shared.selectedGames = selectedGames
                    OnboardingScoreStore.shared.stakes = Dictionary(uniqueKeysWithValues: selectedGames.compactMap { game in
                        stakes[game].flatMap { Double($0) }.map { (game, $0) }
                    })
                    OnboardingScoreStore.shared.frequencyLabels = frequencies
                    goToTotalHistory = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .opacity(isComplete ? 1 : 0.4)
                .disabled(!isComplete)
            }
        }
        .navigationDestination(isPresented: $goToTotalHistory) {
            TotalHistoryView()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.appSpring.delay(0.1)) {
                isVisible = true
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Parlons chiffres")
                .font(.appTitle)
                .foregroundStyle(Color.appTextPrimary)

            Text("Sois honnête, ça reste entre toi et l'app.")
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 12)
    }

    private func gameCard(for game: GameType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(game.title)
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)

            VStack(alignment: .leading, spacing: 10) {
                Text("À quelle fréquence ?")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)

                VStack(spacing: 8) {
                    ForEach(frequencyOptions, id: \.label) { option in
                        selectableChip(
                            label: option.label,
                            isSelected: frequencies[game] == option.label
                        ) {
                            frequencies[game] = option.label
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Depuis quand tu joues ?")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)

                VStack(spacing: 8) {
                    ForEach(durationOptions, id: \.label) { option in
                        selectableChip(
                            label: option.label,
                            isSelected: durations[game] == option.label
                        ) {
                            durations[game] = option.label
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Mise moyenne par session")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)

                HStack {
                    TextField("0", text: stakeBinding(for: game))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: game)
                        .foregroundStyle(Color.appTextPrimary)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))

                    Text("€")
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.appSurfaceElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(focusedField == game ? Color.appAccent : Color.appBorder, lineWidth: focusedField == game ? 2 : 1)
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.appSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 16)
    }

    private func selectableChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? Color.appBackground : Color.appTextSecondary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appBackground)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.appAccent : Color.appSurfaceElevated)
            )
        }
        .buttonStyle(.plain)
    }

    private func stakeBinding(for game: GameType) -> Binding<String> {
        Binding(
            get: { stakes[game] ?? "" },
            set: { stakes[game] = $0.filter { $0.isNumber } }
        )
    }
}

#Preview {
    NavigationStack {
        PracticeDetailsView(selectedGames: [.casino, .sportsBetting])
    }
}
