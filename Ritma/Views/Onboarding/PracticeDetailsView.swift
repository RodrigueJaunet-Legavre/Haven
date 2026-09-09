import SwiftUI

struct PracticeDetailsView: View {
    let selectedGames: [GameType]

    @State private var goToQuestionnaire = false
    @State private var isVisible = false
    @State private var frequencies: [GameType: String] = [:]
    @State private var stakes: [GameType: String] = [:]
    @FocusState private var focusedField: GameType?

    private let frequencyOptions = ["Quotidien", "Plusieurs fois/semaine", "Une fois/semaine", "Quelques fois/mois", "Rarement"]

    private var isComplete: Bool {
        selectedGames.allSatisfy { game in
            frequencies[game] != nil && !(stakes[game]?.isEmpty ?? true)
        }
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
                    goToQuestionnaire = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .opacity(isComplete ? 1 : 0.4)
                .disabled(!isComplete)
            }
        }
        .navigationDestination(isPresented: $goToQuestionnaire) {
            PGSIQuestionnaireView()
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
                    ForEach(frequencyOptions, id: \.self) { option in
                        frequencyChip(option: option, game: game)
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

    private func frequencyChip(option: String, game: GameType) -> some View {
        let isSelected = frequencies[game] == option

        return Button {
            withAnimation(.appSpringSnappy) {
                frequencies[game] = option
            }
        } label: {
            HStack {
                Text(option)
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
