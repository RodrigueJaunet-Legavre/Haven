import SwiftUI

struct AddVictoryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var note = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Qu'est-ce qui s'est passé ? (facultatif)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)

                        TextEditor(text: $note)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(height: 140)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14).fill(Color.appSurfaceElevated)
                            )
                    }

                    Spacer()

                    Button(isSaving ? "Enregistrement..." : "Enregistrer") {
                        Task { await save() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isSaving)
                }
                .padding(24)
                .padding(.top, 20)
            }
            .navigationTitle("Nouvelle victoire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    private func save() async {
        isSaving = true
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        await VictoryService.shared.addEntry(note: trimmed.isEmpty ? nil : trimmed)
        isSaving = false
        dismiss()
    }
}

#Preview {
    AddVictoryView()
}
