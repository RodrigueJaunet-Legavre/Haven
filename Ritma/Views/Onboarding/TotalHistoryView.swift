import SwiftUI

struct TotalHistoryView: View {
    @State private var isVisible = false
    @State private var totalWageredText = ""
    @State private var isNetWin = false
    @State private var netAmountText = ""
    @State private var goToQuestionnaire = false
    @FocusState private var focusedField: Bool

    private var isComplete: Bool {
        !totalWageredText.isEmpty && !netAmountText.isEmpty
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 40)

                        VStack(spacing: 8) {
                            Text("Un dernier chiffre")
                                .font(.appTitle)
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Une estimation suffit, personne ne vérifie.")
                                .font(.appBody)
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Total misé depuis que tu joues")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.appTextSecondary)

                            amountField(text: $totalWageredText)
                        }
                        .padding(.horizontal, 28)

                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Au global, je suis plutôt gagnant", isOn: $isNetWin)
                                .tint(Color.appAccent)
                                .foregroundStyle(Color.appTextPrimary)

                            Text(isNetWin ? "Montant gagné au total" : "Montant perdu au total")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.appTextSecondary)

                            amountField(text: $netAmountText)
                        }
                        .padding(.horizontal, 28)
                    }
                }

                Button("Continuer") {
                    finalize()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 40)
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

    private func amountField(text: Binding<String>) -> some View {
        HStack {
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .focused($focusedField)
                .foregroundStyle(Color.appTextPrimary)
                .font(.system(size: 17, weight: .semibold, design: .rounded))

            Text("€")
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.appSurfaceElevated)
        )
    }

    private func wageredImpact(_ amount: Double) -> Int {
        switch amount {
        case ..<1000: return 0
        case 1000..<5000: return 5
        case 5000..<15000: return 10
        case 15000..<50000: return 15
        default: return 20
        }
    }

    private func lossImpact(_ amount: Double) -> Int {
        switch amount {
        case ..<500: return 0
        case 500..<2000: return 5
        case 2000..<5000: return 10
        case 5000..<15000: return 15
        default: return 20
        }
    }

    private func finalize() {
        let wagered = Double(totalWageredText) ?? 0
        let netAmount = Double(netAmountText) ?? 0

        let wImpact = wageredImpact(wagered)
        let lImpact = isNetWin ? 0 : lossImpact(netAmount)

        OnboardingScoreStore.shared.totalHistoryImpact = wImpact + lImpact
        goToQuestionnaire = true
    }
}

#Preview {
    NavigationStack {
        TotalHistoryView()
    }
}
