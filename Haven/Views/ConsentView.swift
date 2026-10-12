import SwiftUI

struct ConsentView: View {
    @ObservedObject private var consentStore = ConsentStore.shared
    @State private var accepted = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer(minLength: 24)

                        ZStack {
                            Circle()
                                .fill(Color.appAccentMuted)
                                .frame(width: 64, height: 64)

                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(Color.appAccent)
                        }

                        Text("Avant de commencer")
                            .font(.appTitle)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Haven garde ton journal, tes victoires et ton check-in sur ton compte pour t'aider à reprendre la main. Ces informations décrivent ton rapport au jeu : la loi les considère comme des données de santé, qui demandent ton accord explicite.")
                            .font(.appBody)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: 10) {
                            infoRow(
                                icon: "icloud.fill",
                                title: "Sur ton compte en ligne",
                                text: "Ton e-mail, ton journal, tes victoires et ton check-in quotidien."
                            )
                            infoRow(
                                icon: "iphone",
                                title: "Sur ton appareil seulement",
                                text: "Ton test, ton parcours, tes raisons Emergency et ton contact de confiance."
                            )
                            infoRow(
                                icon: "hand.raised.fill",
                                title: "Jamais",
                                text: "De publicité, de revente de données ni de suivi."
                            )
                        }

                        Link(destination: PrivacyPolicy.url) {
                            HStack(spacing: 6) {
                                Text("Lire la politique de confidentialité")
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                        }

                        Button {
                            accepted.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: accepted ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 22))
                                    .foregroundStyle(accepted ? Color.appAccent : Color.appTextMuted)

                                Text("J'ai lu la politique de confidentialité et j'accepte que Haven traite mes données de santé (journal, victoires, check-in) pour faire fonctionner l'app. Je peux retirer mon accord à tout moment en supprimant mon compte.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
                }

                VStack(spacing: 10) {
                    if let errorMessage = consentStore.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appDanger)
                            .multilineTextAlignment(.center)
                    }

                    Button(consentStore.isSaving ? "..." : "Continuer") {
                        Task { await consentStore.accept() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!accepted || consentStore.isSaving)
                    .opacity(accepted ? 1 : 0.4)

                    Button("Refuser et me déconnecter") {
                        Task { try? await AuthService.shared.signOut() }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appTextMuted)
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
    }

    private func infoRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }
}

#Preview {
    ConsentView()
}
