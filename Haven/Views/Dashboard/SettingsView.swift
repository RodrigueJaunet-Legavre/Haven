import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authService = AuthService.shared
    @ObservedObject private var trustedContactStore = TrustedContactStore.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    @State private var notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
    @State private var showSignOutConfirmation = false
    @State private var isGeneratingPDF = false
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deleteErrorMessage: String?

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

                        trustedContactCard

                        exportCard

                        privacyCard

                        signOutButton

                        deleteAccountSection
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
            .confirmationDialog("Supprimer définitivement ton compte ?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Supprimer mon compte", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ton compte et toutes tes données (journal, victoires, check-in, progression) seront effacés, sans retour possible, et le blocage de tes applications et sites sera désactivé. Si ton compte a été créé avec Apple, une confirmation Apple te sera demandée pour couper le lien avec Haven. Ton abonnement n'est pas annulé automatiquement : résilie-le dans les réglages de ton compte Apple.")
            }
            .alert("Suppression impossible", isPresented: Binding(
                get: { deleteErrorMessage != nil },
                set: { if !$0 { deleteErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(deleteErrorMessage ?? "")
            }
            .sheet(isPresented: $showShareSheet) {
                if let pdfURL {
                    ShareSheet(activityItems: [pdfURL])
                }
            }
        }
    }

    private var trustedContactCard: some View {
        sectionCard(title: "Contact de confiance") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Si tu vis un moment difficile (envies répétées, rechutes rapprochées), Haven te proposera de le prévenir facilement.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)

                TextField("Nom", text: $trustedContactStore.name)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appSurfaceElevated))

                TextField("Numéro de téléphone", text: $trustedContactStore.phone)
                    .keyboardType(.phonePad)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appSurfaceElevated))
            }
        }
    }

    private var exportCard: some View {
        sectionCard(title: "Mes données") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Génère un PDF récapitulatif (test initial, score de vitalité, badges, historique) à garder pour toi ou à montrer à un professionnel.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)

                Button {
                    Task { await exportPDF() }
                } label: {
                    Text(isGeneratingPDF ? "Génération..." : "Exporter en PDF")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appAccent)
                }
                .disabled(isGeneratingPDF)
            }
        }
    }

    private var privacyCard: some View {
        sectionCard(title: "Confidentialité") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tes données de santé sont traitées avec ton accord, que tu peux retirer à tout moment en supprimant ton compte.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)

                Link(destination: PrivacyPolicy.url) {
                    HStack(spacing: 6) {
                        Text("Politique de confidentialité")
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                }
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appGold)

                    Text(subscriptionManager.isSubscribed ? "Abonnement actif" : "Aucun abonnement actif")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    Spacer()
                }

                Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                    HStack(spacing: 6) {
                        Text("Gérer mon abonnement")
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                }
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

    private var deleteAccountSection: some View {
        VStack(spacing: 8) {
            Button {
                showDeleteConfirmation = true
            } label: {
                Text(isDeleting ? "Suppression..." : "Supprimer mon compte")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appDanger)
            }
            .disabled(isDeleting)

            Text("Efface définitivement ton compte et toutes tes données.")
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMuted)
        }
        .padding(.top, 4)
    }

    private func exportPDF() async {
        isGeneratingPDF = true
        let data = await PDFReportGenerator.generate()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Haven-rapport.pdf")
        try? data.write(to: url)
        pdfURL = url
        isGeneratingPDF = false
        showShareSheet = true
    }

    private func signOut() async {
        try? await authService.signOut()
    }

    private func deleteAccount() async {
        isDeleting = true
        do {
            try await authService.deleteAccount()
        } catch {
            deleteErrorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Ton compte n'a pas pu être supprimé pour le moment. Vérifie ta connexion et réessaie. Si ça persiste, contacte le support."
        }
        isDeleting = false
    }
}

#Preview {
    SettingsView()
}
