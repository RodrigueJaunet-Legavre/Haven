import SwiftUI

struct EmergencySetupView: View {
    @ObservedObject private var store = EmergencyReasonsStore.shared
    @State private var newReasonText = ""
    @State private var goToHome = false
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)

                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.appAccentMuted)
                                    .frame(width: 64, height: 64)

                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Color.appAccent)
                            }

                            Text("Configure ton bouton Emergency")
                                .font(.appTitle)
                                .foregroundStyle(Color.appTextPrimary)
                                .multilineTextAlignment(.center)

                            Text("En cas d'envie de rejouer, tu pourras relire tes propres raisons de tenir bon. Ajoute-en au moins 3 pour continuer.")
                                .font(.appBody)
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 28)

                        VStack(spacing: 10) {
                            ForEach(store.reasons) { reason in
                                reasonRow(reason)
                            }
                        }
                        .padding(.horizontal, 28)

                        addReasonField
                            .padding(.horizontal, 28)
                    }
                }

                Button("Continuer") {
                    goToHome = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 40)
                .opacity(store.reasons.count >= 3 ? 1 : 0.4)
                .disabled(store.reasons.count < 3)
            }
        }
        .navigationDestination(isPresented: $goToHome) {
            HomeTabView()
        }
        .navigationBarHidden(true)
    }

    private func reasonRow(_ reason: EmergencyReason) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.appAccent)

            Text("pour \(reason.text)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button {
                if let index = store.reasons.firstIndex(where: { $0.id == reason.id }) {
                    store.deleteReason(at: IndexSet(integer: index))
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextMuted)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private var addReasonField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Je décide d'arrêter les jeux d'argent pour")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)

            HStack(spacing: 10) {
                TextField("ma fille, mes économies, ma dignité...", text: $newReasonText)
                    .focused($isFieldFocused)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14).fill(Color.appSurfaceElevated)
                    )
                    .onSubmit { addReason() }

                Button {
                    addReason()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    private func addReason() {
        let trimmed = newReasonText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addReason(trimmed)
        newReasonText = ""
    }
}

#Preview {
    NavigationStack {
        EmergencySetupView()
    }
}
