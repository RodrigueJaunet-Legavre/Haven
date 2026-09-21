import SwiftUI

struct AddBetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedGame: GameType = .casino
    @State private var montantText = ""
    @State private var isWin = false
    @State private var amountText = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    Picker("Jeu", selection: $selectedGame) {
                        Text(GameType.casino.title).tag(GameType.casino)
                        Text(GameType.sportsBetting.title).tag(GameType.sportsBetting)
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Montant misé")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                        amountField(text: $montantText)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("J'ai gagné", isOn: $isWin)
                            .tint(Color.appAccent)
                            .foregroundStyle(Color.appTextPrimary)

                        Text(isWin ? "Montant gagné" : "Montant perdu")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                        amountField(text: $amountText)
                    }

                    Spacer()

                    Button(isSaving ? "Enregistrement..." : "Enregistrer") {
                        Task { await save() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(montantText.isEmpty || amountText.isEmpty || isSaving)
                }
                .padding(24)
                .padding(.top, 20)
            }
            .navigationTitle("Nouvelle entrée")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    private func amountField(text: Binding<String>) -> some View {
        HStack {
            TextField("0", text: text)
                .keyboardType(.numberPad)
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

    private func save() async {
        guard let montant = Double(montantText), let amount = Double(amountText) else { return }
        isSaving = true
        let gainPerte = isWin ? amount : -amount
        await BetsService.shared.addEntry(typeJeu: selectedGame.title, montant: montant, gainPerte: gainPerte)
        isSaving = false
        dismiss()
    }
}

#Preview {
    AddBetView()
}
