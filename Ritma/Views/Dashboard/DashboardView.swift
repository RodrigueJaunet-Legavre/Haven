import SwiftUI

struct DashboardView: View {
    @ObservedObject private var store = AvatarStore.shared
    @ObservedObject private var streakStore = StreakStore.shared
    @ObservedObject private var completionStore = ActivityCompletionStore.shared
    @ObservedObject private var checkInService = CheckInService.shared
    @State private var showSettings = false
    @State private var showRelapseConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer(minLength: 20)

                        AvatarView(config: store.config, vitalityScore: store.vitalityScore)

                        if !checkInService.hasCheckedInToday {
                            checkInCard
                        }

                        VStack(spacing: 6) {
                            Text("\(streakStore.streakDays) jour\(streakStore.streakDays > 1 ? "s" : "") sans jouer")
                                .font(.appHeadline)
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Score de vitalité : \(Int(store.vitalityScore))/100")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        NavigationLink {
                            AvatarCreatorView()
                        } label: {
                            Text("Personnaliser mon avatar")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.appAccent)
                        }

                        NavigationLink {
                            BadgesView()
                        } label: {
                            Text("Voir mes badges")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.appAccent)
                        }

                        Button {
                            showRelapseConfirm = true
                        } label: {
                            Text("J'ai rechuté")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appDanger)
                        }

                        debugSection
                    }
                    .padding(.horizontal, 28)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .confirmationDialog("Tu as recommencé à jouer ?", isPresented: $showRelapseConfirm, titleVisibility: .visible) {
                Button("Oui, enregistrer", role: .destructive) {
                    Task {
                        await BetsService.shared.addEntry(typeJeu: "Rechute", montant: 0, gainPerte: nil)
                        await streakStore.refresh()
                        TrustedContactStore.shared.recordRelapse()
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ça reste entre toi et l'app. Ton score de vitalité et ta série de jours vont être mis à jour en conséquence.")
            }
            .task {
                await streakStore.refresh()
                await checkInService.fetchEntries()
            }
        }
    }

    private var checkInCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comment te sens-tu aujourd'hui ?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 6) {
                ForEach(CheckInLevel.allCases) { level in
                    Button {
                        Task { await checkInService.addEntry(intensity: level.rawValue) }
                    } label: {
                        VStack(spacing: 4) {
                            Text(level.emoji)
                                .font(.system(size: 26))
                            Text(level.label)
                                .font(.system(size: 9))
                                .foregroundStyle(Color.appTextMuted)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Réglage de test (temporaire)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextMuted)

            Slider(value: $store.vitalityScore, in: 0...100)
                .tint(Color.appAccent)

            Button("Réinitialiser les activités du jour") {
                completionStore.resetToday()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.appDanger)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface)
        )
        .padding(.top, 20)
    }
}

#Preview {
    DashboardView()
}
