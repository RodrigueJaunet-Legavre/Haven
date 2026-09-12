import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared

    @State private var notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
    @State private var showSignOutConfirmation = false
    @State private var showSignedOutAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileCard

                        subscriptionCard

                        sectionCard(title: "Notifications") {
                            Toggle("Rappels et encouragements", isOn: $notificationsEnabled)
                                .tint(Color.appAccent)
                                .foregroundStyle(Color.appTextPrimary)
                                .onChange(of: notificationsEnabled) { _, newValue in
                                    UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                                }
                        }

                        signOutButton
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Réglages")
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .confirmationDialog("Te déconnecter ?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                Button("Me déconnecter", role: .destructive) {
                    Task { await signOut() }
                }
                Button("Annuler", role: .cancel) {}
            }
            .alert("Déconnecté", isPresented: $showSignedOutAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Relance l'application pour revenir à l'écran de connexion.")
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appAccentMuted)
                    .frame(width: 52, height: 52)

                Image(systemName: "person.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(authService.currentUserEmail ?? "Compte")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Membre Haven")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
        )
    }

    private var subscriptionCard: some View {
        sectionCard(title: "Abonnement") {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Essai gratuit en cours")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Gestion de l'abonnement à venir")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextMuted)
                }

                Spacer()
            }
        }
    }

    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
                )
        }
    }

    private var signOutButton: some View {
        Button {
            showSignOutConfirmation = true
        } label: {
            Text("Me déconnecter")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appDanger)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(Color.appDanger.opacity(0.12))
                )
        }
    }

    private func signOut() async {
        try? await authService.signOut()
        showSignedOutAlert = true
    }
}

#Preview {
    SettingsView()
}
